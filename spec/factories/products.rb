FactoryBot.define do
  factory :product do
    name { "MyString" }
    description { "MyText" }
    price { "9.99" }
    available { false }
    stock { 1 }
    business { nil }
  end
end
