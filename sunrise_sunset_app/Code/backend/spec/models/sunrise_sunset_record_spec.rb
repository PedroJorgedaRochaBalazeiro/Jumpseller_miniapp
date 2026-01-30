# spec/models/sunrise_sunset_record_spec.rb
require 'rails_helper'

RSpec.describe SunriseSunsetRecord, type: :model do
  describe 'validations' do
    subject { build(:sunrise_sunset_record) }
    
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:latitude) }
    it { should validate_presence_of(:longitude) }
    it { should validate_presence_of(:date) }
    
    it { should validate_numericality_of(:latitude)
          .is_greater_than_or_equal_to(-90)
          .is_less_than_or_equal_to(90) }
    
    it { should validate_numericality_of(:longitude)
          .is_greater_than_or_equal_to(-180)
          .is_less_than_or_equal_to(180) }
    
    it 'validates uniqueness of location scoped to date' do
      create(:sunrise_sunset_record, location: 'Lisbon', date: Date.today)
      duplicate = build(:sunrise_sunset_record, location: 'Lisbon', date: Date.today)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:location]).to include('already has a record for this date')
    end
  end
  
  describe 'scopes' do
    before do
      create(:sunrise_sunset_record, location: 'Lisbon', date: Date.today)
      create(:sunrise_sunset_record, location: 'Berlin', date: Date.today)
      create(:sunrise_sunset_record, location: 'Lisbon', date: Date.yesterday)
    end
    
    describe '.for_location' do
      it 'returns records for specific location' do
        results = SunriseSunsetRecord.for_location('Lisbon')
        expect(results.count).to eq(2)
        expect(results.pluck(:location).uniq).to eq(['Lisbon'])
      end
    end
    
    describe '.for_date_range' do
      it 'returns records within date range' do
        results = SunriseSunsetRecord.for_date_range(Date.yesterday, Date.today)
        expect(results.count).to eq(3)
      end
    end
    
    describe '.by_date' do
      it 'orders records by date ascending' do
        results = SunriseSunsetRecord.by_date
        dates = results.pluck(:date)
        expect(dates).to eq(dates.sort)
      end
    end
  end
  
  describe '.find_or_fetch' do
    let(:location) { 'Lisbon' }
    let(:start_date) { Date.today }
    let(:end_date) { Date.today + 2.days }
    
    before do
      # Create record for today only
      create(:sunrise_sunset_record, location: location, date: Date.today)
    end
    
    it 'identifies existing and missing dates' do
      result = SunriseSunsetRecord.find_or_fetch(
        location: location,
        start_date: start_date,
        end_date: end_date
      )
      
      expect(result[:existing].count).to eq(1)
      expect(result[:missing_dates].count).to eq(2)
      expect(result[:missing_dates]).to include(Date.today + 1.day, Date.today + 2.days)
    end
  end
  
  describe '#polar_region?' do
    it 'returns true when status includes POLAR' do
      record = build(:sunrise_sunset_record, status: 'POLAR_NIGHT')
      expect(record.polar_region?).to be true
    end
    
    it 'returns false when status does not include POLAR' do
      record = build(:sunrise_sunset_record, status: nil)
      expect(record.polar_region?).to be false
    end
  end
  
  describe '#has_sunrise?' do
    it 'returns true when sunrise is present' do
      record = build(:sunrise_sunset_record, sunrise: '7:45:23 AM')
      expect(record.has_sunrise?).to be true
    end
    
    it 'returns false when sunrise is N/A' do
      record = build(:sunrise_sunset_record, sunrise: 'N/A')
      expect(record.has_sunrise?).to be false
    end
  end
  
  describe '#to_chart_data' do
    let(:record) { create(:sunrise_sunset_record) }
    
    it 'converts record to chart-friendly format' do
      data = record.to_chart_data
      
      expect(data).to have_key(:date)
      expect(data).to have_key(:sunrise)
      expect(data).to have_key(:sunset)
      expect(data).to have_key(:day_length_minutes)
    end
  end
end