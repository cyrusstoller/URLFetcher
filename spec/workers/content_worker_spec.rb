require "spec_helper"

describe ContentWorker do
  before(:each) do
    @url = "https://www.google.com"
    @web_contents = "<html><body>hello world</body></html>"
    @content = FactoryGirl.create(:content, :url => @url, :body => nil)
  end
  
  describe "successful status for url to be fetched" do
    it "should add the body to the content model without a callback url for a 200" do
      stub_request(:get, @url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => @web_contents, :headers => { 'Content-Length' => @web_contents.length })
      
      ContentWorker.perform(@content.id)
      @content.reload.body.should == @web_contents
    end
    
    it "should add the body to the content model without a callback url for a 302" do
      redirected_to_url = "http://cs.swarthmore.edu/"
      stub_request(:get, @url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 302, :body => "w", :headers => { 'Content-Length' => 1 , 'Location' => redirected_to_url})
      stub_request(:get, redirected_to_url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => @web_contents, :headers => { 'Content-Length' => @web_contents.length })
      ContentWorker.perform(@content.id)
      @content.reload.body.should == @web_contents
      @content.num_redirects.should == 1
      @content.final_url == redirected_to_url
    end
  end
  
  describe "404 status on url to be fetched" do
    it "should add the body to the content model without a callback url" do
      stub_request(:get, @url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 404, :body => @web_contents, :headers => { 'Content-Length' => @web_contents.length })
      
      ContentWorker.perform(@content.id)
      @content.reload.body.should be_nil
    end
    
    it "should not change the callback count" do
      stub_request(:get, @url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 404, :body => @web_contents, :headers => { 'Content-Length' => @web_contents.length })
      
      expect {
        ContentWorker.perform(@content.id)
      }.to_not change(Callback, :count)
    end
    
    it "should change the flag to 1" do
      stub_request(:get, @url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 404, :body => @web_contents, :headers => { 'Content-Length' => @web_contents.length })
      
      ContentWorker.perform(@content.id)
      @content.reload.flag.should == 1
    end
    
    it "should send a callback to notify the user that the fetch failed" do
      callback_url = "http://cs.swarthmore.edu/"
      @content.callback_url = callback_url
      @content.save
      stub_request(:get, @url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 404, :body => @web_contents, :headers => { 'Content-Length' => @web_contents.length })
      stub_request(:post, callback_url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => "woo", :headers => { 'Content-Length' => 3})
      expect {
        ContentWorker.perform(@content.id)
      }.to change(Callback, :count).by(1)
    end
  end
  
  describe "callback 200" do
    it "should post back to the callback url" do
      callback_url = "http://cs.swarthmore.edu/"
      @content.callback_url = callback_url
      @content.save
      stub_request(:get, @url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => @web_contents, :headers => { 'Content-Length' => @web_contents.length })
      stub_request(:post, callback_url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => "woo", :headers => { 'Content-Length' => 3})
      expect {
        ContentWorker.perform(@content.id)
      }.to change(Callback, :count).by(1)
    end
  end

  describe "callback 404" do
    it "should post back to the callback url" do
      callback_url = "http://cs.swarthmore.edu/"
      @content.callback_url = callback_url
      @content.save
      stub_request(:get, @url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => @web_contents, :headers => { 'Content-Length' => @web_contents.length })
      stub_request(:post, callback_url).
               with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
               to_return(:status => 404, :body => "woo", :headers => { 'Content-Length' => 3})
      expect {
        ContentWorker.perform(@content.id)
      }.to change(Callback, :count).by(1)

      @content.reload.flag.should == 1 # to show that the callback url was questionable
    end
  end
  
end