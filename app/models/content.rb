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

class Content < ActiveRecord::Base
  attr_accessible :callback_url, :url, :user_id
  
  has_many :callbacks, :as => :callbackable, :dependent => :destroy
  
  validates_presence_of :url
  validates_format_of :url, :with => URI::regexp(%w(http https))
  validates_format_of :callback_url, :with => URI::regexp(%w(http https)), :unless => Proc.new { |p| p.callback_url.blank? }
  
  def set_flag_clean!
    self.flag = 0
    self.save
  end
  
  def set_flag_questionable!
    unless self.flag > 1
      self.flag = 1 
      self.save
    end
  end
  
  def set_flag_malicious!
    self.flag = 2
    self.save
  end
  
  def add_redirect(new_url)
    self.final_url = new_url
    self.num_redirects += 1
    self.save
  end
end
