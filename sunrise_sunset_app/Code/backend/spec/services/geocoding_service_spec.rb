# spec/services/geocoding_service_spec.rb
require 'rails_helper'

RSpec.describe GeocodingService do
  before(:each) { Rails.cache.clear }
  describe '.coordinates_for' do
    let(:location) { 'Lisbon' }
    
    context 'when location is found' do
      let(:geocoder_result) do
        double(
          latitude: 38.7223,
          longitude: -9.1393,
          display_name: 'Lisbon, Portugal',
          country: 'Portugal',
          city: 'Lisbon'
        )
      end
      
      before do
        allow(Geocoder).to receive(:search).with(location).and_return([geocoder_result])
      end
      
      it 'returns coordinates' do
        result = described_class.coordinates_for(location)
        
        expect(result[:latitude]).to eq(38.7223)
        expect(result[:longitude]).to eq(-9.1393)
        expect(result[:formatted_address]).to eq('Lisbon, Portugal')
      end

      it 'caches the result' do
        described_class.coordinates_for(location)

        expect(Geocoder).not_to receive(:search)
        described_class.coordinates_for(location)
      end
    end
    
    context 'when location is not found' do
      before do
        allow(Geocoder).to receive(:search).with(location).and_return([])
      end
      
      it 'raises LocationNotFoundError' do
        expect {
          described_class.coordinates_for(location)
        }.to raise_error(GeocodingService::LocationNotFoundError, /not found/)
      end
    end
    
    context 'when location is empty' do
      it 'raises GeocodingError' do
        expect {
          described_class.coordinates_for('')
        }.to raise_error(GeocodingService::GeocodingError, /cannot be empty/)
      end
    end
    
    context 'when geocoder raises error' do
      before do
        allow(Geocoder).to receive(:search).and_raise(Geocoder::OverQueryLimitError)
      end
      
      it 'raises GeocodingError with appropriate message' do
        expect {
          described_class.coordinates_for(location)
        }.to raise_error(GeocodingService::GeocodingError, /rate limit/)
      end
    end
  end
end