# spec/controllers/api/v1/sunrise_sunsets_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::SunriseSunsetsController, type: :request do
  let(:valid_params) do
    {
      location: 'Lisbon',
      start_date: '2024-01-01',
      end_date: '2024-01-03'
    }
  end
  
  let(:geocoding_response) do
    {
      latitude: 38.7223,
      longitude: -9.1393,
      formatted_address: 'Lisbon, Portugal'
    }
  end
  
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
        },
        {
          date: '2024-01-03',
          sunrise: '7:45:37 AM',
          sunset: '5:31:45 PM',
          solar_noon: '12:38:11 PM',
          day_length: '09:46:08',
          golden_hour: '6:16:00 AM',
          golden_hour_end: '6:17:00 PM',
          timezone: 'Europe/Lisbon'
        }
      ]
    }
  end
  
  describe 'POST /api/v1/sunrise_sunsets' do
    context 'with valid parameters' do
      before do
        allow(GeocodingService).to receive(:coordinates_for)
          .with('Lisbon')
          .and_return(geocoding_response)
        
        stub_request(:get, %r{https://api\.sunrisesunset\.io/json})
          .with(query: hash_including({
            lat: '38.7223',
            lng: '-9.1393'
          }))
          .to_return(
            status: 200,
            body: api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it 'creates records and returns data' do
        post '/api/v1/sunrise_sunsets', params: valid_params
        
        expect(response).to have_http_status(:ok)
        
        json = JSON.parse(response.body)
        expect(json['data']).to be_an(Array)
        expect(json['data'].length).to eq(3)
        expect(json['data'].first['attributes']['location']).to eq('Lisbon')
        expect(json['data'].first['attributes']['sunrise']).to eq('7:45:23 AM')
      end
      
      it 'does not create duplicate records' do
        # First request
        post '/api/v1/sunrise_sunsets', params: valid_params
        expect(SunriseSunsetRecord.count).to eq(3)
        
        # Second request with same parameters
        post '/api/v1/sunrise_sunsets', params: valid_params
        expect(SunriseSunsetRecord.count).to eq(3) # No duplicates
      end
      
      it 'fetches only missing data on subsequent requests' do
        # Create records for first two days
        create(:sunrise_sunset_record, 
               location: 'Lisbon', 
               date: Date.parse('2024-01-01'),
               latitude: 38.7223,
               longitude: -9.1393)
        create(:sunrise_sunset_record, 
               location: 'Lisbon', 
               date: Date.parse('2024-01-02'),
               latitude: 38.7223,
               longitude: -9.1393)
        
        # Should only fetch data for 2024-01-03
        post '/api/v1/sunrise_sunsets', params: valid_params
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data'].length).to eq(3)
      end
    end
    
    context 'with invalid location' do
      before do
        allow(GeocodingService).to receive(:coordinates_for)
          .and_raise(GeocodingService::LocationNotFoundError, 'Location not found')
      end
      
      it 'returns error' do
        post '/api/v1/sunrise_sunsets', params: valid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']['code']).to eq('LOCATION_NOT_FOUND')
        expect(json['error']['message']).to include('not found')
      end
    end
    
    context 'with missing parameters' do
      it 'returns error when location is missing' do
        post '/api/v1/sunrise_sunsets', params: { start_date: '2024-01-01', end_date: '2024-01-03' }
        
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']['code']).to eq('MISSING_PARAMETER')
      end
      
      it 'returns error when dates are missing' do
        post '/api/v1/sunrise_sunsets', params: { location: 'Lisbon' }
        
        expect(response).to have_http_status(:bad_request)
      end
    end
    
    context 'with invalid date range' do
      before do
        allow(GeocodingService).to receive(:coordinates_for).and_return(geocoding_response)
      end
      
      it 'returns error when end date is before start date' do
        invalid_params = valid_params.merge(start_date: '2024-01-10', end_date: '2024-01-01')
        post '/api/v1/sunrise_sunsets', params: invalid_params
        
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['error']['code']).to eq('INVALID_DATE_RANGE')
      end
    end
    
    context 'when external API fails' do
      before do
        allow(GeocodingService).to receive(:coordinates_for).and_return(geocoding_response)
        
        stub_request(:get, %r{https://api\.sunrisesunset\.io/json})
          .to_return(status: 500)
      end
      
      it 'returns error' do
        post '/api/v1/sunrise_sunsets', params: valid_params
        
        expect(response).to have_http_status(:bad_gateway)
        json = JSON.parse(response.body)
        expect(json['error']['code']).to eq('EXTERNAL_API_ERROR')
      end
    end
  end
  
  describe 'GET /api/v1/sunrise_sunsets' do
    before do
      create(:sunrise_sunset_record, location: 'Lisbon', date: Date.parse('2024-01-01'))
      create(:sunrise_sunset_record, location: 'Berlin', date: Date.parse('2024-01-01'))
      create(:sunrise_sunset_record, location: 'Lisbon', date: Date.parse('2024-01-02'))
    end
    
    it 'returns all records' do
      get '/api/v1/sunrise_sunsets'
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(3)
    end
    
    it 'filters by location' do
      get '/api/v1/sunrise_sunsets', params: { location: 'Lisbon' }
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(2)
      expect(json['data'].all? { |r| r['attributes']['location'] == 'Lisbon' }).to be true
    end
    
    it 'filters by date range' do
      get '/api/v1/sunrise_sunsets', params: { 
        start_date: '2024-01-01', 
        end_date: '2024-01-01' 
      }
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(2)
    end
  end
  
  describe 'GET /api/v1/sunrise_sunsets/:id' do
    let!(:record) { create(:sunrise_sunset_record) }
    
    it 'returns the record' do
      get "/api/v1/sunrise_sunsets/#{record.id}"
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(record.id.to_s)
    end
    
    it 'returns not found for invalid id' do
      get '/api/v1/sunrise_sunsets/99999'
      
      expect(response).to have_http_status(:not_found)
    end
  end
  
  describe 'DELETE /api/v1/sunrise_sunsets/:id' do
    let!(:record) { create(:sunrise_sunset_record) }
    
    it 'deletes the record' do
      expect {
        delete "/api/v1/sunrise_sunsets/#{record.id}"
      }.to change(SunriseSunsetRecord, :count).by(-1)
      
      expect(response).to have_http_status(:no_content)
    end
    
    it 'returns not found for invalid id' do
      delete '/api/v1/sunrise_sunsets/99999'
      
      expect(response).to have_http_status(:not_found)
    end
  end
end