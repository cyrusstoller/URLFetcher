require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
    auth_admin
  end

  describe "GET 'welcome'" do
    it "returns http success" do
      get 'welcome'
      response.should be_success
    end
  end

  describe "GET 'docs'" do
    it "returns http success" do
      get 'docs'
      response.should be_success
    end
  end

end
