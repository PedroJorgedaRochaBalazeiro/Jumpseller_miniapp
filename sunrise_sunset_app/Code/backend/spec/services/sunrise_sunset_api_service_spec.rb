# spec/services/sunrise_sunset_api_service_spec.rb
require 'rails_helper'

RSpec.describe SunriseSunsetApiService do
  let(:latitude) { 38.7223 }
  let(:longitude) { -9.1393 }
  let(:start_date) { '2024-01-01' }
  let(:end_date) { '2024-01-03' }
  
  let(:service) do
    described_class.new(
      latitude: latitude,
      longitude: longitude,
      start_date: start_date,
      end_date: end_date
    )
  end
  
  describe '#fetch_data' do
    context 'with successful API response' do
      let(:api_response) do
        {
          status: 'OK',
          results: [
            {
              date: '2024-01-01',
              sunrise: '7:45:23 AM',
              sunset: '5:30:15 PM',
              solar_noon: '12:37:49 PM',
              day_length: '09:44:52',
              golden_hour: '6:15:00 AM',
              golden_hour_end: '6:15:00 PM',
              timezone: 'Europe/Lisbon'
            },
            {
              date: '2024-01-02',
              sunrise: '7:45:30 AM',
              sunset: '5:31:00 PM',
              solar_noon: '12:38:00 PM',
              day_length: '09:45:30',
              golden_hour: '6:15:30 AM',
              golden_hour_end: '6:16:00 PM',
              timezone: 'Europe/Lisbon'
            }
          ]
        }
      end
      
      before do
        stub_request(:get, %r{https://api\.sunrisesunset\.io/json})
          .with(query: hash_including({
            lat: latitude.to_s,
            lng: longitude.to_s,
            date_start: start_date,
            date_end: end_date
          }))
          .to_return(
            status: 200,
            body: api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it 'returns parsed results' do
        results = service.fetch_data
        
        expect(results).to be_an(Array)
        expect(results.length).to eq(2)
        expect(results.first['sunrise']).to eq('7:45:23 AM')
      end
    end
    
    context 'with empty results' do
      before do
        stub_request(:get, %r{https://api\.sunrisesunset\.io/json})
          .to_return(
            status: 200,
            body: { status: 'OK', results: [] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it 'returns empty array' do
        results = service.fetch_data
        expect(results).to eq([])
      end
    end
    
    context 'with API error status' do
      before do
        stub_request(:get, %r{https://api\.sunrisesunset\.io/json})
          .to_return(
            status: 200,
            body: { status: 'INVALID_REQUEST' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it 'raises ApiError' do
        expect {
          service.fetch_data
        }.to raise_error(SunriseSunsetApiService::ApiError, /Invalid request/)
      end
    end
    
    context 'with HTTP error' do
      before do
        stub_request(:get, %r{https://api\.sunrisesunset\.io/json})
          .to_return(status: 500)
      end
      
      it 'raises ApiError' do
        expect {
          service.fetch_data
        }.to raise_error(SunriseSunsetApiService::ApiError)
      end
    end
    
    context 'with rate limit error' do
      before do
        stub_request(:get, %r{https://api\.sunrisesunset\.io/json})
          .to_return(status: 429)
      end
      
      it 'raises RateLimitError' do
        expect {
          service.fetch_data
        }.to raise_error(SunriseSunsetApiService::RateLimitError, /rate limit/)
      end
    end
    
    context 'with invalid JSON response' do
      before do
        stub_request(:get, %r{https://api\.sunrisesunset\.io/json})
          .to_return(
            status: 200,
            body: 'invalid json',
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it 'raises InvalidResponseError' do
        expect {
          service.fetch_data
        }.to raise_error(SunriseSunsetApiService::InvalidResponseError)
      end
    end
  end
  
  describe 'validation' do
    context 'with invalid date range' do
      it 'raises error when end date is before start date' do
        service = described_class.new(
          latitude: latitude,
          longitude: longitude,
          start_date: '2024-01-10',
          end_date: '2024-01-01'
        )
        
        expect {
          service.fetch_data
        }.to raise_error(SunriseSunsetApiService::InvalidDateRangeError, /after/)
      end
      
      it 'raises error when date range exceeds 365 days' do
        service = described_class.new(
          latitude: latitude,
          longitude: longitude,
          start_date: '2024-01-01',
          end_date: '2025-01-02'
        )
        
        expect {
          service.fetch_data
        }.to raise_error(SunriseSunsetApiService::InvalidDateRangeError, /cannot exceed/)
      end
    end
    
    context 'with invalid coordinates' do
      it 'raises error for invalid latitude' do
        service = described_class.new(
          latitude: 91,
          longitude: longitude,
          start_date: start_date,
          end_date: end_date
        )
        
        expect {
          service.fetch_data
        }.to raise_error(SunriseSunsetApiService::ApiError, /Latitude/)
      end
    end
  end
end