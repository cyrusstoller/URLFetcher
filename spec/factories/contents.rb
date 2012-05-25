# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :content do
    url "http://www.example.com/"
    body "MyText"
    user_id 0
    flag 0
  end
end
