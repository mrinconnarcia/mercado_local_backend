FactoryBot.define do
  factory :review do
    order { nil }
    user { nil }
    business { nil }
    rating { 1 }
    comment { "MyText" }
  end
end
