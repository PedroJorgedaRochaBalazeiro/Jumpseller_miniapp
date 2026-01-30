# app/models/sunrise_sunset_record.rb
class SunriseSunsetRecord < ApplicationRecord
  # Validations
  validates :location, presence: true
  validates :latitude, presence: true, 
            numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true,
            numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :date, presence: true
  validates :location, uniqueness: { scope: :date, message: "already has a record for this date" }
  
  # Scopes
  scope :for_location, ->(location) { where(location: location) }
  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_date, -> { order(date: :asc) }
  
  # Class methods
  def self.find_or_fetch(location:, start_date:, end_date:)
    # Parse dates
    start_d = Date.parse(start_date.to_s)
    end_d = Date.parse(end_date.to_s)
    
    # Get existing records
    existing_records = for_location(location)
                        .for_date_range(start_d, end_d)
                        .by_date
    
    # Calculate missing dates
    date_range = (start_d..end_d).to_a
    existing_dates = existing_records.pluck(:date)
    missing_dates = date_range - existing_dates
    
    {
      existing: existing_records,
      missing_dates: missing_dates
    }
  end
  
  def self.locations_list
    distinct.pluck(:location).sort
  end
  
  # Instance methods
  def polar_region?
    status.present? && (status.include?('POLAR') || status.include?('MIDNIGHT'))
  end
  
  def has_sunrise?
    sunrise.present? && sunrise != 'N/A'
  end
  
  def has_sunset?
    sunset.present? && sunset != 'N/A'
  end
  
  def to_chart_data
    {
      date: date.to_s,
      sunrise: parse_time_to_decimal(sunrise),
      sunset: parse_time_to_decimal(sunset),
      day_length_minutes: parse_duration_to_minutes(day_length)
    }
  end
  
  private
  
  def parse_time_to_decimal(time_string)
    return nil unless time_string.present? && time_string != 'N/A'
    
    begin
      time = Time.parse(time_string)
      time.hour + (time.min / 60.0)
    rescue ArgumentError
      nil
    end
  end
  
  def parse_duration_to_minutes(duration_string)
    return nil unless duration_string.present?
    
    parts = duration_string.split(':').map(&:to_i)
    return nil if parts.length < 3
    
    (parts[0] * 60) + parts[1] + (parts[2] / 60.0)
  end
end