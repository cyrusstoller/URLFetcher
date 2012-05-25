# == Schema Information
# Schema version: 20120522071141
#
# Table name: contents
#
#  id            :integer         not null, primary key
#  url           :string(255)
#  body          :text
#  callback_url  :string(255)
#  user_id       :integer         default(0)
#  flag          :integer         default(0)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  final_url     :string(255)
#  num_redirects :integer         default(0)
#

require 'spec_helper'

describe Content do
  describe "validation" do
    it "should be valid with all fields" do
      FactoryGirl.build(:content).should be_valid
    end
    
    it "should be valid with a url and no callback url" do
      FactoryGirl.build(:content, :callback_url => nil).should be_valid
    end
    
    it "should not be valid without a url" do
      FactoryGirl.build(:content, :url => nil).should_not be_valid
    end
    
    it "should not be valid with a bad url" do
      FactoryGirl.build(:content, :url => "asdfk").should_not be_valid
    end
    
    it "should not be valid with a bad url" do
      FactoryGirl.build(:content, :callback_url => "asdfk").should_not be_valid
    end    
  end
  
  describe "set flag" do
    it "should respond to set_flag_clean" do
      FactoryGirl.build(:content).should respond_to(:set_flag_clean!)
    end
    
    it "should change the flag value to 0" do
      c = FactoryGirl.create(:content, :flag => 2)
      c.set_flag_clean!
      c.flag.should == 0
    end
    
    it "should respond to set_flag_questionable" do
      FactoryGirl.build(:content).should respond_to(:set_flag_questionable!)
    end
    
    it "should change the flag value to 1" do
      c = FactoryGirl.create(:content, :flag => 0)
      c.set_flag_questionable!
      c.flag.should == 1
    end
    
    it "should not change the flag value" do
      c = FactoryGirl.create(:content, :flag => 2)
      c.set_flag_questionable!
      c.flag.should == 2
    end
    
    it "should respond to set_flag_malicious" do
      FactoryGirl.build(:content).should respond_to(:set_flag_malicious!)
    end
    
    it "should change the flag value to 2" do
      c = FactoryGirl.create(:content, :flag => 1)
      c.set_flag_malicious!
      c.flag.should == 2
    end
  end
  
  describe "callbacks" do
    it "should respond to callbacks" do
      FactoryGirl.build(:content, :flag => 0).should respond_to(:callbacks)
    end
  end
  
  describe "redirects" do
    it "should respond to add_redirect" do
      FactoryGirl.build(:content, :flag => 0).should respond_to(:add_redirect)
    end
    
    it "should add the new_url and increment the num_redirects" do
      c = FactoryGirl.create(:content, :flag => 0)
      new_url = "http://www.swarthmore.edu/"
      expect {
        c.add_redirect(new_url)
      }.to change(c.reload, :num_redirects).by(1)
      c.final_url.should == new_url
    end
  end
end
