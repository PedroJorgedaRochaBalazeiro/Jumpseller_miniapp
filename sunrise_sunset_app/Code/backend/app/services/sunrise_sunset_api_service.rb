# app/services/sunrise_sunset_api_service.rb
class SunriseSunsetApiService
  include HTTParty
  base_uri 'https://api.sunrisesunset.io'
  
  class ApiError < StandardError; end
  class RateLimitError < ApiError; end
  class InvalidResponseError < ApiError; end
  class InvalidDateRangeError < ApiError; end
  
  MAX_DATE_RANGE = 365
  DEFAULT_TIMEOUT = 15
  
  def initialize(latitude:, longitude:, start_date:, end_date:, timezone: nil)
    @latitude = latitude
    @longitude = longitude
    @start_date = start_date
    @end_date = end_date
    @timezone = timezone
  end
  
  def fetch_data
    validate_parameters!
    validate_date_range!
    
    response = self.class.get('/json', 
      query: query_params, 
      timeout: DEFAULT_TIMEOUT,
      headers: {
        'User-Agent' => 'SunriseSunsetApp/1.0'
      }
    )
    
    handle_response(response)
  rescue HTTParty::Error => e
    raise ApiError, "HTTP request failed: #{e.message}"
  rescue Timeout::Error
    raise ApiError, "Request timed out. The API might be slow or unavailable."
  rescue SocketError => e
    raise ApiError, "Network error: #{e.message}. Please check your internet connection."
  end
  
  private
  
  def query_params
    {
      lat: @latitude,
      lng: @longitude,
      date_start: @start_date,
      date_end: @end_date,
      timezone: @timezone
    }.compact
  end
  
  def validate_parameters!
    if @latitude.nil? || @longitude.nil?
      raise ApiError, "Latitude and longitude are required"
    end
    
    unless @latitude.between?(-90, 90)
      raise ApiError, "Latitude must be between -90 and 90"
    end
    
    unless @longitude.between?(-180, 180)
      raise ApiError, "Longitude must be between -180 and 180"
    end
  end
  
  def validate_date_range!
    start_d = Date.parse(@start_date.to_s)
    end_d = Date.parse(@end_date.to_s)
    
    if end_d < start_d
      raise InvalidDateRangeError, 'End date must be after or equal to start date'
    end
    
    days_diff = (end_d - start_d).to_i
    if days_diff > MAX_DATE_RANGE
      raise InvalidDateRangeError, "Date range cannot exceed #{MAX_DATE_RANGE} days. Requested: #{days_diff} days"
    end
  rescue ArgumentError => e
    raise InvalidDateRangeError, "Invalid date format: #{e.message}"
  end
  
  def handle_response(response)
    unless response.success?
      handle_http_error(response)
    end
    
    body = parse_response_body(response)
    
    # Check API status
    status = body['status']
    unless status == 'OK'
      handle_api_status(status, body)
    end
    
    results = body['results']
    
    # Handle empty results (might be valid for polar regions)
    if results.nil? || results.empty?
      Rails.logger.warn("API returned no results for coordinates: #{@latitude}, #{@longitude}")
      return []
    end
    
    # Ensure results is an array
    results = [results] unless results.is_a?(Array)
    
    results
  end
  
  def parse_response_body(response)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise InvalidResponseError, "Invalid JSON response: #{e.message}"
  end
  
  def handle_http_error(response)
    case response.code
    when 429
      raise RateLimitError, "API rate limit exceeded. Please try again later."
    when 400
      raise ApiError, "Bad request: Invalid parameters"
    when 500..599
      raise ApiError, "API server error (#{response.code}). Please try again later."
    else
      raise ApiError, "API returned error status #{response.code}"
    end
  end
  
  def handle_api_status(status, body)
    case status
    when 'INVALID_REQUEST'
      raise ApiError, "Invalid request: #{body['error_message'] || 'Unknown error'}"
    when 'INVALID_DATE'
      raise InvalidDateRangeError, "Invalid date format"
    when 'ZERO_RESULTS'
      # This might be valid for polar regions during certain times of year
      Rails.logger.info("Zero results returned - might be polar region")
      return []
    else
      raise ApiError, "API error: #{status}"
    end
  end
end