FactoryBot.define do
  factory :comment do
    content { "MyText" }
    task { nil }
    user { nil }
  end
end
