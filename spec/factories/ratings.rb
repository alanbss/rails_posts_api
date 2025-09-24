FactoryBot.define do
  factory :rating do
    value { 5 }
    association :post
    association :user
  end
end
