FactoryBot.define do
  factory :business_hour do
    business { nil }
    day_of_week { 1 }
    opens_at { "2026-09-16 12:36:00" }
    closes_at { "2026-09-16 12:36:00" }
    closed { false }
  end
end
