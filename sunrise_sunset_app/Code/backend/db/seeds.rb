# db/seeds.rb

puts "🌱 Seeding database..."

# Sample locations
locations = [
  { name: "Lisbon", lat: 38.7223, lng: -9.1393 },
  { name: "Berlin", lat: 52.5200, lng: 13.4050 },
  { name: "Tokyo", lat: 35.6762, lng: 139.6503 }
]

# Sample dates (last 7 days)
dates = (7.days.ago.to_date..Date.today).to_a

locations.each do |location|
  puts "Creating records for #{location[:name]}..."
  
  dates.each do |date|
    # Skip if record already exists
    next if SunriseSunsetRecord.exists?(location: location[:name], date: date)
    
    # Create sample record with realistic data
    hour_offset = rand(-2..2)
    
    SunriseSunsetRecord.create!(
      location: location[:name],
      latitude: location[:lat],
      longitude: location[:lng],
      date: date,
      sunrise: (7 + hour_offset).hours.since(date.beginning_of_day).strftime('%I:%M:%S %p'),
      sunset: (17 + hour_offset).hours.since(date.beginning_of_day).strftime('%I:%M:%S %p'),
      solar_noon: "12:00:00 PM",
      day_length: "10:00:00",
      civil_twilight_begin: (6 + hour_offset).hours.since(date.beginning_of_day).strftime('%I:%M:%S %p'),
      civil_twilight_end: (18 + hour_offset).hours.since(date.beginning_of_day).strftime('%I:%M:%S %p'),
      golden_hour: (6.5 + hour_offset).hours.since(date.beginning_of_day).strftime('%I:%M:%S %p'),
      golden_hour_end: (17.5 + hour_offset).hours.since(date.beginning_of_day).strftime('%I:%M:%S %p'),
      timezone: "UTC"
    )
  end
end

puts "✅ Seeding complete!"
puts "Created #{SunriseSunsetRecord.count} records for #{locations.length} locations"