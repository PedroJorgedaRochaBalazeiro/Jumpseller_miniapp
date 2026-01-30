# app/serializers/sunrise_sunset_serializer.rb
class SunriseSunsetSerializer
  include JSONAPI::Serializer
  
  set_type :sunrise_sunset_record
  
  attributes :location, 
             :latitude, 
             :longitude, 
             :date,
             :sunrise, 
             :sunset, 
             :solar_noon, 
             :day_length,
             :civil_twilight_begin, 
             :civil_twilight_end,
             :nautical_twilight_begin, 
             :nautical_twilight_end,
             :astronomical_twilight_begin, 
             :astronomical_twilight_end,
             :golden_hour, 
             :golden_hour_end,
             :timezone, 
             :status
  
  attribute :formatted_date do |object|
    object.date.strftime('%Y-%m-%d')
  end
  
  attribute :day_length_minutes do |object|
    next nil unless object.day_length.present?
    
    parts = object.day_length.split(':').map(&:to_i)
    next nil if parts.length < 3
    
    (parts[0] * 60) + parts[1] + (parts[2] / 60.0).round(2)
  end
  
  attribute :is_polar_region do |object|
    object.polar_region?
  end
end