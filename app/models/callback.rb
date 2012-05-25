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

class Callback < ActiveRecord::Base
  attr_accessible :status

  belongs_to :callbackable, :polymorphic => true
  
  validates_presence_of :callbackable_id
  validates_presence_of :callbackable_type
  validates_presence_of :status
end
