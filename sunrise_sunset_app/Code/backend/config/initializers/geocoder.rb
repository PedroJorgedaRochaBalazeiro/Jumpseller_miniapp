# config/initializers/geocoder.rb
Geocoder.configure(
  # Timeouts
  timeout: 10,
  
  # Geocoding service
  lookup: :nominatim,
  
  # Use HTTPS
  use_https: true,
  
  # Nominatim (OpenStreetMap) configuration
  nominatim: {
    email: ENV.fetch('GEOCODER_EMAIL', 'pedrobalazeiro20@gmail.com')
  },

  http_headers: {
    "User-Agent" => "sunrise-sunset-app (pedrobalazeiro20@gmail.com)"
  },

  # Caching
  cache: Rails.cache,
  cache_prefix: 'geocoder:',
  
  # Always use cache (don't make external requests in test)
  always_raise: [
    Geocoder::OverQueryLimitError,
    Geocoder::RequestDenied,
    Geocoder::InvalidRequest,
    Geocoder::InvalidApiKey
  ]
)