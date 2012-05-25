# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :callback do
    callbackable_id 1
    callbackable_type "MyString"
    status 200
  end
end
