FactoryBot.define do
  factory :post do
    title { "Sample Post Title" }
    body { "This is a sample post body with some content." }
    ip { "192.168.1.1" }
    association :user
  end
end
