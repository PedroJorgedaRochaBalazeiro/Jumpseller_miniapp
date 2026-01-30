# spec/factories/sunrise_sunset_records.rb
FactoryBot.define do
  factory :sunrise_sunset_record do
    location { "Lisbon" }
    latitude { 38.7223 }
    longitude { -9.1393 }
    date { Date.today }
    sunrise { "7:45:23 AM" }
    sunset { "5:30:15 PM" }
    solar_noon { "12:37:49 PM" }
    day_length { "09:44:52" }
    civil_twilight_begin { "7:15:00 AM" }
    civil_twilight_end { "6:00:38 PM" }
    nautical_twilight_begin { "6:40:31 AM" }
    nautical_twilight_end { "6:35:07 PM" }
    astronomical_twilight_begin { "6:06:53 AM" }
    astronomical_twilight_end { "7:08:45 PM" }
    golden_hour { "6:15:00 AM" }
    golden_hour_end { "6:15:00 PM" }
    timezone { "Europe/Lisbon" }
    
    trait :berlin do
      location { "Berlin" }
      latitude { 52.5200 }
      longitude { 13.4050 }
      timezone { "Europe/Berlin" }
    end
    
    trait :tokyo do
      location { "Tokyo" }
      latitude { 35.6762 }
      longitude { 139.6503 }
      timezone { "Asia/Tokyo" }
    end
    
    trait :with_polar_status do
      status { "POLAR_NIGHT" }
      sunrise { "N/A" }
      sunset { "N/A" }
      solar_noon { "N/A" }
      day_length { "00:00:00" }
    end
    
    trait :yesterday do
      date { Date.yesterday }
    end
    
    trait :last_week do
      date { 1.week.ago.to_date }
    end
  end
end