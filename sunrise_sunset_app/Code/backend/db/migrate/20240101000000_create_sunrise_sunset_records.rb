# db/migrate/20240101000000_create_sunrise_sunset_records.rb
class CreateSunriseSunsetRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :sunrise_sunset_records do |t|
      # Location information
      t.string :location, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.date :date, null: false
      
      # Sun times
      t.string :sunrise
      t.string :sunset
      t.string :solar_noon
      t.string :day_length
      
      # Twilight periods
      t.string :civil_twilight_begin
      t.string :civil_twilight_end
      t.string :nautical_twilight_begin
      t.string :nautical_twilight_end
      t.string :astronomical_twilight_begin
      t.string :astronomical_twilight_end
      
      # Golden hours
      t.string :golden_hour
      t.string :golden_hour_end
      
      # Metadata
      t.string :timezone
      t.string :status # For special cases (polar night, midnight sun, etc)

      t.timestamps
    end
    
    # Indexes for performance
    add_index :sunrise_sunset_records, [:location, :date], unique: true, name: 'index_sunrise_sunset_on_location_and_date'
    add_index :sunrise_sunset_records, [:latitude, :longitude, :date], name: 'index_sunrise_sunset_on_coords_and_date'
    add_index :sunrise_sunset_records, :date
    add_index :sunrise_sunset_records, :created_at
  end
end