FactoryBot.define do
  factory :post do
    title { "MyString" }
    body { "MyText" }
    ip { "MyString" }
    user { nil }
  end
end
