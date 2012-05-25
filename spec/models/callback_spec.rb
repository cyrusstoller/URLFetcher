# == Schema Information
# Schema version: 20120522040631
#
# Table name: callbacks
#
#  id                :integer         not null, primary key
#  callbackable_id   :integer
#  callbackable_type :string(255)
#  status            :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

require 'spec_helper'

describe Callback do
  describe "callbackable" do
    it "should respond to callbackable" do
      FactoryGirl.build(:callback).should respond_to(:callbackable)
    end
  end
  
  describe "validations" do
    it "should not be valid without a status" do
      FactoryGirl.build(:callback, :status => nil).should_not be_valid
    end
    
    it "should not be valid without a callbackable id" do
      FactoryGirl.build(:callback, :callbackable_id => nil).should_not be_valid
    end
  end
end
