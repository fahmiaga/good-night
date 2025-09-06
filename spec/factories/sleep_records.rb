# spec/factories/sleep_records.rb
FactoryBot.define do
  factory :sleep_record do
    association :user
    start_time { 1.hour.ago }

    # default clocked out record
    end_time { start_time + 30.minutes }

    duration_seconds { end_time ? (end_time - start_time).to_i : nil }

    trait :active do
      end_time { nil }          # belum clock out
      duration_seconds { nil }
    end

    trait :clocked_out do
      after(:build) do |record|
        record.end_time ||= record.start_time + 30.minutes
        record.duration_seconds ||= (record.end_time - record.start_time).to_i
      end
    end
  end
end
