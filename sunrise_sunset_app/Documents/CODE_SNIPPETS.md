# Snippets de Código Úteis - Sunrise Sunset App

Este arquivo contém snippets de código prontos para usar no desenvolvimento do projeto.

## 📦 BACKEND SNIPPETS

### 1. Gemfile Completo

```ruby
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Core
gem 'rails', '~> 7.1.0'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.0'

# API & HTTP
gem 'rack-cors'
gem 'httparty'
gem 'geocoder'
gem 'jsonapi-serializer'

# Reduce boot times
gem 'bootsnap', require: false

group :development, :test do
  gem 'debug', platforms: %i[ mri windows ]
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'dotenv-rails'
end

group :test do
  gem 'webmock'
  gem 'vcr'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'database_cleaner-active_record'
  gem 'simplecov', require: false
end

group :development do
  gem 'annotate'
end
```

### 2. Comandos de Setup do Rails

```bash
# Criar projeto
rails new sunrise-sunset-backend --api --database=postgresql --skip-test

cd sunrise-sunset-backend

# Adicionar gems ao Gemfile (use o Gemfile acima)

# Instalar
bundle install

# Gerar model
rails g model SunriseSunsetRecord location:string latitude:decimal longitude:decimal date:date sunrise:string sunset:string solar_noon:string day_length:string civil_twilight_begin:string civil_twilight_end:string nautical_twilight_begin:string nautical_twilight_end:string astronomical_twilight_begin:string astronomical_twilight_end:string golden_hour:string golden_hour_end:string timezone:string status:string

# Gerar controller
rails g controller api/v1/SunriseSunsets

# Setup RSpec
rails generate rspec:install

# Criar e migrar DB
rails db:create db:migrate
```

### 3. Config CORS Completa

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3001', 'localhost:5173', '127.0.0.1:3001', '127.0.0.1:5173'
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization'],
      credentials: true
  end
end
```

### 4. Routes Completo

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :sunrise_sunsets, only: [:index, :create, :show, :destroy]
      
      # Rotas adicionais úteis
      get 'locations/search', to: 'locations#search'
    end
  end
  
  # Health check para monitoramento
  get '/health', to: proc { [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok' }.to_json]] }
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  # root "articles#index"
end
```

### 5. RSpec Configuration

```ruby
# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
require 'webmock/rspec'
require 'vcr'

# Disable external HTTP requests
WebMock.disable_net_connect!(allow_localhost: true)

# VCR configuration
VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true
end

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  # Factory Bot
  config.include FactoryBot::Syntax::Methods
  
  # Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

# Shoulda Matchers
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

### 6. Factory Bot Example

```ruby
# spec/factories/sunrise_sunset_records.rb
FactoryBot.define do
  factory :sunrise_sunset_record do
    location { "Lisbon" }
    latitude { 38.7223 }
    longitude { -9.1393 }
    date { Date.today }
    sunrise { "7:45:23 AM" }
    sunset { "5:30:15 PM" }
    solar_noon { "12:37:49 PM" }
    day_length { "09:44:52" }
    civil_twilight_begin { "7:15:00 AM" }
    civil_twilight_end { "6:00:38 PM" }
    golden_hour { "6:15:00 AM" }
    golden_hour_end { "6:15:00 PM" }
    timezone { "Europe/Lisbon" }
    
    trait :with_polar_status do
      status { "POLAR_NIGHT" }
      sunrise { nil }
      sunset { nil }
    end
  end
end
```

### 7. Controller Spec Example

```ruby
# spec/requests/api/v1/sunrise_sunsets_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::SunriseSunsets", type: :request do
  describe "POST /api/v1/sunrise_sunsets" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          location: "Lisbon",
          start_date: "2024-01-01",
          end_date: "2024-01-03"
        }
      end
      
      before do
        # Mock do GeocodingService
        allow(GeocodingService).to receive(:coordinates_for).and_return({
          latitude: 38.7223,
          longitude: -9.1393,
          formatted_address: "Lisbon, Portugal"
        })
        
        # Mock da API externa
        stub_request(:get, "https://api.sunrisesunset.io/json")
          .with(query: hash_including({ lat: "38.7223", lng: "-9.1393" }))
          .to_return(
            status: 200,
            body: {
              status: "OK",
              results: [
                {
                  date: "2024-01-01",
                  sunrise: "7:45:23 AM",
                  sunset: "5:30:15 PM",
                  solar_noon: "12:37:49 PM",
                  day_length: "09:44:52",
                  golden_hour: "6:15:00 AM",
                  golden_hour_end: "6:15:00 PM"
                }
              ]
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      
      it "creates new records and returns data" do
        post "/api/v1/sunrise_sunsets", params: valid_params
        
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']).to be_an(Array)
        expect(json['data'].first['attributes']['location']).to eq('Lisbon')
      end
    end
    
    context "with invalid location" do
      it "returns error" do
        allow(GeocodingService).to receive(:coordinates_for)
          .and_raise(GeocodingService::GeocodingError, "Location not found")
        
        post "/api/v1/sunrise_sunsets", params: { 
          location: "InvalidCity", 
          start_date: "2024-01-01", 
          end_date: "2024-01-03" 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']['code']).to eq('INVALID_LOCATION')
      end
    end
  end
end
```

---

## 🎨 FRONTEND SNIPPETS

### 1. package.json Completo

```json
{
  "name": "sunrise-sunset-frontend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext js,jsx",
    "format": "prettier --write \"src/**/*.{js,jsx,css}\""
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.2",
    "recharts": "^2.10.3",
    "date-fns": "^3.0.6",
    "react-datepicker": "^4.25.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@vitejs/plugin-react": "^4.2.1",
    "vite": "^5.0.8",
    "eslint": "^8.55.0",
    "eslint-plugin-react": "^7.33.2",
    "eslint-plugin-react-hooks": "^4.6.0",
    "prettier": "^3.1.1"
  }
}
```

### 2. API Service Completo

```javascript
// src/services/apiService.js
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000, // 30 seconds
});

// Interceptor para logging (desenvolvimento)
apiClient.interceptors.request.use(
  (config) => {
    console.log('📤 API Request:', config.method.toUpperCase(), config.url);
    return config;
  },
  (error) => {
    console.error('❌ Request Error:', error);
    return Promise.reject(error);
  }
);

apiClient.interceptors.response.use(
  (response) => {
    console.log('📥 API Response:', response.status, response.config.url);
    return response;
  },
  (error) => {
    console.error('❌ Response Error:', error.response?.status, error.message);
    return Promise.reject(error);
  }
);

export const sunriseSunsetAPI = {
  // Fetch sunrise/sunset data
  fetchData: async (location, startDate, endDate) => {
    try {
      const response = await apiClient.post('/sunrise_sunsets', {
        location,
        start_date: startDate,
        end_date: endDate,
      });
      return response.data;
    } catch (error) {
      throw handleApiError(error);
    }
  },

  // Get existing records (optional)
  getRecords: async (filters = {}) => {
    try {
      const response = await apiClient.get('/sunrise_sunsets', {
        params: filters,
      });
      return response.data;
    } catch (error) {
      throw handleApiError(error);
    }
  },

  // Health check
  healthCheck: async () => {
    try {
      const response = await axios.get(`${API_BASE_URL.replace('/api/v1', '')}/health`);
      return response.data;
    } catch (error) {
      throw new Error('Backend is not responding');
    }
  },
};

// Error handler
function handleApiError(error) {
  if (error.response) {
    // Server responded with error
    const { status, data } = error.response;
    
    switch (status) {
      case 400:
        return new Error(data.error?.message || 'Invalid request parameters');
      case 422:
        return new Error(data.error?.message || 'Location not found');
      case 502:
        return new Error(data.error?.message || 'External API error');
      default:
        return new Error(data.error?.message || 'An error occurred');
    }
  } else if (error.request) {
    // Request made but no response
    return new Error('No response from server. Please check your connection.');
  } else {
    // Something else happened
    return new Error(error.message || 'An unexpected error occurred');
  }
}

export default apiClient;
```

### 3. Custom Hook para Fetch

```javascript
// src/hooks/useSunriseSunsetData.js
import { useState, useCallback } from 'react';
import { sunriseSunsetAPI } from '../services/apiService';

export const useSunriseSunsetData = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchData = useCallback(async (location, startDate, endDate) => {
    setLoading(true);
    setError(null);
    setData(null);

    try {
      const response = await sunriseSunsetAPI.fetchData(location, startDate, endDate);
      setData(response.data);
      return response.data;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const reset = useCallback(() => {
    setData(null);
    setError(null);
    setLoading(false);
  }, []);

  return {
    data,
    loading,
    error,
    fetchData,
    reset,
  };
};
```

### 4. Componente LocationForm

```javascript
// src/components/LocationForm.jsx
import React, { useState } from 'react';
import DatePicker from 'react-datepicker';
import { format, subDays, addDays } from 'date-fns';
import 'react-datepicker/dist/react-datepicker.css';
import './LocationForm.css';

const LocationForm = ({ onSubmit, loading }) => {
  const [location, setLocation] = useState('');
  const [startDate, setStartDate] = useState(subDays(new Date(), 7));
  const [endDate, setEndDate] = useState(new Date());

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (!location.trim()) {
      alert('Please enter a location');
      return;
    }
    
    if (endDate < startDate) {
      alert('End date must be after start date');
      return;
    }
    
    const daysDiff = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24));
    if (daysDiff > 365) {
      alert('Date range cannot exceed 365 days');
      return;
    }

    onSubmit({
      location: location.trim(),
      startDate: format(startDate, 'yyyy-MM-dd'),
      endDate: format(endDate, 'yyyy-MM-dd'),
    });
  };

  return (
    <form onSubmit={handleSubmit} className="location-form">
      <div className="form-group">
        <label htmlFor="location">Location</label>
        <input
          id="location"
          type="text"
          value={location}
          onChange={(e) => setLocation(e.target.value)}
          placeholder="e.g., Lisbon, Berlin, Tokyo"
          disabled={loading}
          className="form-input"
        />
      </div>

      <div className="form-row">
        <div className="form-group">
          <label htmlFor="start-date">Start Date</label>
          <DatePicker
            id="start-date"
            selected={startDate}
            onChange={(date) => setStartDate(date)}
            maxDate={endDate}
            dateFormat="yyyy-MM-dd"
            disabled={loading}
            className="form-input"
          />
        </div>

        <div className="form-group">
          <label htmlFor="end-date">End Date</label>
          <DatePicker
            id="end-date"
            selected={endDate}
            onChange={(date) => setEndDate(date)}
            minDate={startDate}
            maxDate={addDays(startDate, 365)}
            dateFormat="yyyy-MM-dd"
            disabled={loading}
            className="form-input"
          />
        </div>
      </div>

      <button type="submit" disabled={loading} className="submit-button">
        {loading ? 'Loading...' : 'Get Sunrise & Sunset Data'}
      </button>
    </form>
  );
};

export default LocationForm;
```

### 5. Componente DataChart

```javascript
// src/components/DataChart.jsx
import React from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';
import { parseTime } from '../utils/dateHelpers';

const DataChart = ({ data }) => {
  if (!data || data.length === 0) {
    return <div className="no-data">No data to display</div>;
  }

  // Transform data for chart
  const chartData = data.map((record) => ({
    date: record.attributes.date,
    sunrise: parseTime(record.attributes.sunrise),
    sunset: parseTime(record.attributes.sunset),
    dayLength: parseDayLength(record.attributes.day_length),
  }));

  return (
    <div className="chart-container">
      <h3>Sunrise & Sunset Times</h3>
      <ResponsiveContainer width="100%" height={400}>
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis 
            dataKey="date" 
            tick={{ fontSize: 12 }}
            angle={-45}
            textAnchor="end"
            height={80}
          />
          <YAxis 
            label={{ value: 'Time (hours)', angle: -90, position: 'insideLeft' }}
            domain={[0, 24]}
          />
          <Tooltip 
            formatter={(value) => `${Math.floor(value)}:${String(Math.floor((value % 1) * 60)).padStart(2, '0')}`}
          />
          <Legend />
          <Line 
            type="monotone" 
            dataKey="sunrise" 
            stroke="#ff9800" 
            name="Sunrise"
            strokeWidth={2}
          />
          <Line 
            type="monotone" 
            dataKey="sunset" 
            stroke="#3f51b5" 
            name="Sunset"
            strokeWidth={2}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};

// Helper: Convert time string to decimal hours
function parseDayLength(dayLength) {
  if (!dayLength) return 0;
  const [hours, minutes, seconds] = dayLength.split(':').map(Number);
  return hours + minutes / 60 + seconds / 3600;
}

export default DataChart;
```

### 6. Componente DataTable

```javascript
// src/components/DataTable.jsx
import React from 'react';
import './DataTable.css';

const DataTable = ({ data }) => {
  if (!data || data.length === 0) {
    return <div className="no-data">No data to display</div>;
  }

  return (
    <div className="table-container">
      <h3>Detailed Data</h3>
      <div className="table-wrapper">
        <table className="data-table">
          <thead>
            <tr>
              <th>Date</th>
              <th>Sunrise</th>
              <th>Sunset</th>
              <th>Solar Noon</th>
              <th>Day Length</th>
              <th>Golden Hour (AM)</th>
              <th>Golden Hour (PM)</th>
            </tr>
          </thead>
          <tbody>
            {data.map((record) => (
              <tr key={record.id}>
                <td>{record.attributes.date}</td>
                <td>{record.attributes.sunrise || 'N/A'}</td>
                <td>{record.attributes.sunset || 'N/A'}</td>
                <td>{record.attributes.solar_noon || 'N/A'}</td>
                <td>{record.attributes.day_length || 'N/A'}</td>
                <td>{record.attributes.golden_hour || 'N/A'}</td>
                <td>{record.attributes.golden_hour_end || 'N/A'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default DataTable;
```

### 7. App.jsx Completo

```javascript
// src/App.jsx
import React from 'react';
import LocationForm from './components/LocationForm';
import DataChart from './components/DataChart';
import DataTable from './components/DataTable';
import LoadingSpinner from './components/LoadingSpinner';
import ErrorMessage from './components/ErrorMessage';
import { useSunriseSunsetData } from './hooks/useSunriseSunsetData';
import './App.css';

function App() {
  const { data, loading, error, fetchData, reset } = useSunriseSunsetData();

  const handleSubmit = async (formData) => {
    try {
      await fetchData(formData.location, formData.startDate, formData.endDate);
    } catch (err) {
      // Error is already set by the hook
      console.error('Error fetching data:', err);
    }
  };

  return (
    <div className="app">
      <header className="app-header">
        <h1>🌅 Sunrise & Sunset Tracker</h1>
        <p>Get historical sunrise and sunset data for any location</p>
      </header>

      <main className="app-main">
        <div className="form-section">
          <LocationForm onSubmit={handleSubmit} loading={loading} />
        </div>

        {loading && <LoadingSpinner />}

        {error && <ErrorMessage message={error} onDismiss={reset} />}

        {data && !loading && (
          <div className="results-section">
            <DataChart data={data} />
            <DataTable data={data} />
          </div>
        )}

        {!data && !loading && !error && (
          <div className="empty-state">
            <p>👆 Enter a location and date range above to get started</p>
          </div>
        )}
      </main>

      <footer className="app-footer">
        <p>Data provided by SunriseSunset.io API</p>
      </footer>
    </div>
  );
}

export default App;
```

### 8. Helpers Utilities

```javascript
// src/utils/dateHelpers.js
import { parse, format } from 'date-fns';

/**
 * Convert time string "7:45:23 AM" to decimal hours
 */
export function parseTime(timeString) {
  if (!timeString) return null;
  
  try {
    const date = parse(timeString, 'h:mm:ss a', new Date());
    return date.getHours() + date.getMinutes() / 60;
  } catch (error) {
    console.error('Error parsing time:', error);
    return null;
  }
}

/**
 * Format date for display
 */
export function formatDate(dateString) {
  try {
    const date = new Date(dateString);
    return format(date, 'MMM dd, yyyy');
  } catch (error) {
    return dateString;
  }
}

/**
 * Convert duration string "09:44:52" to minutes
 */
export function durationToMinutes(duration) {
  if (!duration) return 0;
  
  const [hours, minutes, seconds] = duration.split(':').map(Number);
  return hours * 60 + minutes + seconds / 60;
}
```

### 9. CSS Base Styles

```css
/* src/App.css */
:root {
  --primary-color: #3f51b5;
  --secondary-color: #ff9800;
  --error-color: #f44336;
  --success-color: #4caf50;
  --background: #f5f5f5;
  --card-background: #ffffff;
  --text-primary: #333333;
  --text-secondary: #666666;
  --border-color: #e0e0e0;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: var(--background);
  color: var(--text-primary);
}

.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.app-header {
  background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
  color: white;
  padding: 2rem;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.app-header h1 {
  margin-bottom: 0.5rem;
}

.app-main {
  flex: 1;
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
  padding: 2rem;
}

.form-section {
  background: var(--card-background);
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
}

.results-section {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: var(--text-secondary);
}

.app-footer {
  background: var(--card-background);
  text-align: center;
  padding: 1rem;
  border-top: 1px solid var(--border-color);
  margin-top: 2rem;
}
```

---

## 🚀 Comandos Rápidos

### Backend Quick Start
```bash
cd backend
bundle install
rails db:create db:migrate db:seed
rails server
```

### Frontend Quick Start
```bash
cd frontend
npm install
npm run dev
```

### Run Tests
```bash
# Backend
cd backend && bundle exec rspec

# Frontend
cd frontend && npm test
```

### Check API
```bash
curl http://localhost:3000/health
```

---

## 📝 Notas Importantes

1. **CORS**: Certifique-se de que as origins no backend correspondem às portas do frontend
2. **Environment Variables**: Sempre use .env files (nunca commitá-los)
3. **API Keys**: Nominatim requer email de contato
4. **Rate Limiting**: SunriseSunset.io API é gratuita mas pode ter limites
5. **Error Handling**: Sempre tratar erros de rede e validação

Estes snippets devem dar a você uma base sólida para começar o desenvolvimento! 🎉