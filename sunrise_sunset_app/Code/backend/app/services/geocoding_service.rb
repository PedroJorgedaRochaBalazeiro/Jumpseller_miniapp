# app/services/geocoding_service.rb
class GeocodingService
  class GeocodingError < StandardError; end
  class LocationNotFoundError < GeocodingError; end
  
  CACHE_EXPIRY = 30.days
  
  def self.coordinates_for(location)
    new(location).coordinates
  end
  
  def initialize(location)
    @location = location.to_s.strip
    raise GeocodingError, "Location cannot be empty" if @location.blank?
  end
  
  def coordinates
    # Check cache first
    cached = cached_coordinates
    return cached if cached.present?
    
    # Geocode the location
    results = Geocoder.search(@location)
    
    if results.empty?
      raise LocationNotFoundError, "Location '#{@location}' not found. Please check the spelling or try a different format (e.g., 'City, Country')."
    end
    
    result = results.first
    
    coords = {
      latitude: result.latitude,
      longitude: result.longitude,
      formatted_address: result.display_name || @location,
      country: result.country,
      city: result.city || result.town || result.village
    }.compact
    
    # Cache the result
    cache_coordinates(coords)
    
    coords
  rescue Geocoder::OverQueryLimitError => e
    raise GeocodingError, "Geocoding service rate limit exceeded. Please try again later."
  rescue Geocoder::Error => e
    raise GeocodingError, "Geocoding failed: #{e.message}"
  end
  
  private
  
  def cache_key
    "geocoding:#{normalize_location(@location)}"
  end
  
  def normalize_location(loc)
    loc.downcase.gsub(/[^a-z0-9]/, '_')
  end
  
  def cached_coordinates
    Rails.cache.read(cache_key)
  end
  
  def cache_coordinates(coords)
    Rails.cache.write(cache_key, coords, expires_in: CACHE_EXPIRY)
  end
end