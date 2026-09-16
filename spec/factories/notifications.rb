FactoryBot.define do
  factory :notification do
    user { nil }
    title { "MyString" }
    body { "MyText" }
    notification_type { "MyString" }
    read { false }
    notifiable { nil }
  end
end
