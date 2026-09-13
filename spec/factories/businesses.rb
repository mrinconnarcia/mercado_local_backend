FactoryBot.define do
  factory :business do
    name { "MyString" }
    description { "MyText" }
    address { "MyString" }
    phone { "MyString" }
    user { nil }
    category { nil }
    status { 1 }
    active { false }
  end
end
