# app/controllers/api/v1/sunrise_sunsets_controller.rb
module Api
  module V1
    class SunriseSunsetsController < ApplicationController
      # Exception handling
      rescue_from GeocodingService::GeocodingError, with: :handle_geocoding_error
      rescue_from GeocodingService::LocationNotFoundError, with: :handle_location_not_found
      rescue_from SunriseSunsetApiService::ApiError, with: :handle_api_error
      rescue_from SunriseSunsetApiService::InvalidDateRangeError, with: :handle_invalid_date_range
      rescue_from ActionController::ParameterMissing, with: :handle_missing_params
      rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
      
      # POST /api/v1/sunrise_sunsets
      # Creates or fetches sunrise/sunset data for a location and date range
      def create
        # Extract and validate parameters
        location = params.require(:location)
        start_date = params.require(:start_date)
        end_date = params.require(:end_date)
        
        # Validate date range
        if end_date < start_date
          raise SunriseSunsetApiService::InvalidDateRangeError, "End date cannot be before start date"
        end

        Rails.logger.info("Fetching data for location: #{location}, dates: #{start_date} to #{end_date}")
        
        # Step 1: Geocode the location to get coordinates
        coords = GeocodingService.coordinates_for(location)
        Rails.logger.info("Geocoded to: #{coords[:latitude]}, #{coords[:longitude]}")
        
        # Step 2: Check what data we already have in the database
        existing_data = SunriseSunsetRecord.find_or_fetch(
          location: location,
          start_date: start_date,
          end_date: end_date
        )
        
        Rails.logger.info("Found #{existing_data[:existing].count} existing records, #{existing_data[:missing_dates].count} dates to fetch")
        
        # Step 3: Fetch missing data from external API
        if existing_data[:missing_dates].any?
          fetch_and_store_missing_data(
            location: location,
            coords: coords,
            missing_dates: existing_data[:missing_dates],
            start_date: start_date,
            end_date: end_date
          )
        end
        
        # Step 4: Get all records for the requested range (including newly created ones)
        records = SunriseSunsetRecord
                    .for_location(location)
                    .for_date_range(start_date, end_date)
                    .by_date
        
        Rails.logger.info("Returning #{records.count} total records")
        
        # Step 5: Serialize and return the data
        render json: SunriseSunsetSerializer.new(records).serializable_hash, 
               status: :ok
      end
      
      # GET /api/v1/sunrise_sunsets
      # Lists existing records with optional filters
      def index
        location = params[:location]
        start_date = params[:start_date]
        end_date = params[:end_date]
        
        records = SunriseSunsetRecord.all
        records = records.for_location(location) if location.present?
        
        if start_date.present? && end_date.present?
          records = records.for_date_range(start_date, end_date)
        end
        
        records = records.by_date.limit(1000)
        
        render json: SunriseSunsetSerializer.new(records).serializable_hash
      end
      
      # GET /api/v1/sunrise_sunsets/:id
      # Shows a specific record
      def show
        record = SunriseSunsetRecord.find(params[:id])
        render json: SunriseSunsetSerializer.new(record).serializable_hash
      rescue ActiveRecord::RecordNotFound
        render json: { 
          error: {
            message: "Record not found",
            code: 'NOT_FOUND'
          }
        }, status: :not_found
      end
      
      # DELETE /api/v1/sunrise_sunsets/:id
      # Deletes a record
      def destroy
        record = SunriseSunsetRecord.find(params[:id])
        record.destroy
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { 
          error: {
            message: "Record not found",
            code: 'NOT_FOUND'
          }
        }, status: :not_found
      end
      
      private
      
      def fetch_and_store_missing_data(location:, coords:, missing_dates:, start_date:, end_date:)
        # Create API service instance
        service = SunriseSunsetApiService.new(
          latitude: coords[:latitude],
          longitude: coords[:longitude],
          start_date: start_date,
          end_date: end_date
        )
        
        # Fetch data from external API
        api_results = service.fetch_data
        
        # Handle empty results (might be polar region)
        if api_results.empty?
          Rails.logger.warn("No results from API - might be polar region")
          create_placeholder_records(location, coords, missing_dates)
          return
        end
        
        # Create database records for each result
        api_results.each do |result|
          result_date = Date.parse(result['date'])
          
          # Only create records for dates we don't have yet
          next unless missing_dates.include?(result_date)
          
          create_record_from_api_result(location, coords, result)
        end
      rescue SunriseSunsetApiService::ApiError => e
        Rails.logger.error("API Error: #{e.message}")
        # Re-raise to be handled by rescue_from
        raise
      end
      
      def create_record_from_api_result(location, coords, result)
        SunriseSunsetRecord.create!(
          location: location,
          latitude: coords[:latitude],
          longitude: coords[:longitude],
          date: Date.parse(result['date']),
          sunrise: result['sunrise'],
          sunset: result['sunset'],
          solar_noon: result['solar_noon'],
          day_length: result['day_length'],
          civil_twilight_begin: result['civil_twilight_begin'],
          civil_twilight_end: result['civil_twilight_end'],
          nautical_twilight_begin: result['nautical_twilight_begin'],
          nautical_twilight_end: result['nautical_twilight_end'],
          astronomical_twilight_begin: result['astronomical_twilight_begin'],
          astronomical_twilight_end: result['astronomical_twilight_end'],
          golden_hour: result['golden_hour'],
          golden_hour_end: result['golden_hour_end'],
          timezone: result['timezone'],
          status: result['status']
        )
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Failed to create record: #{e.message}")
        # Continue with other records
      end
      
      def create_placeholder_records(location, coords, missing_dates)
        # For polar regions or when API returns no data
        missing_dates.each do |date|
          SunriseSunsetRecord.create!(
            location: location,
            latitude: coords[:latitude],
            longitude: coords[:longitude],
            date: date,
            sunrise: 'N/A',
            sunset: 'N/A',
            solar_noon: 'N/A',
            day_length: '00:00:00',
            status: 'POLAR_REGION_NO_DATA'
          )
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Failed to create placeholder record: #{e.message}")
        end
      end
      
      # Error handlers
      
      def handle_geocoding_error(error)
        render json: { 
          error: {
            message: error.message,
            code: 'GEOCODING_ERROR'
          }
        }, status: :unprocessable_entity
      end
      
      def handle_location_not_found(error)
        render json: { 
          error: {
            message: error.message,
            code: 'LOCATION_NOT_FOUND'
          }
        }, status: :unprocessable_entity
      end
      
      def handle_api_error(error)
        render json: { 
          error: {
            message: error.message,
            code: 'EXTERNAL_API_ERROR'
          }
        }, status: :bad_gateway
      end
      
      def handle_invalid_date_range(error)
        render json: { 
          error: {
            message: error.message,
            code: 'INVALID_DATE_RANGE'
          }
        }, status: :bad_request
      end
      
      def handle_missing_params(error)
        render json: { 
          error: {
            message: "Missing required parameter: #{error.param}",
            code: 'MISSING_PARAMETER'
          }
        }, status: :bad_request
      end
      
      def handle_record_invalid(error)
        render json: { 
          error: {
            message: error.message,
            code: 'VALIDATION_ERROR'
          }
        }, status: :unprocessable_entity
      end
    end
  end
end