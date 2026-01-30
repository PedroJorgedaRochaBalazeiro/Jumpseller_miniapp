# Sunrise Sunset App - Requisitos Técnicos Detalhados

## 1. REQUISITOS DO BACKEND (Ruby)

### 1.1 Setup do Projeto Rails

**Framework:** Ruby on Rails 7.1+ (API mode)
**Ruby Version:** 3.2+
**Database:** PostgreSQL (recomendado) ou SQLite3

```bash
# Comando para criar o projeto
rails new sunrise-sunset-backend --api --database=postgresql
cd sunrise-sunset-backend
```

### 1.2 Gems Necessárias

Adicionar ao `Gemfile`:

```ruby
# Gemfile
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0' # ou superior

gem 'rails', '~> 7.1.0'
gem 'pg' # ou 'sqlite3' se preferir
gem 'puma', '~> 6.0'

# API & HTTP
gem 'rack-cors' # CORS para comunicação com frontend
gem 'httparty' # Cliente HTTP para chamar API externa
gem 'geocoder' # Converter nomes de cidades em coordenadas

# Serialização
gem 'jsonapi-serializer' # ou 'active_model_serializers'

# Background jobs (opcional, para otimização futura)
# gem 'sidekiq'

group :development, :test do
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'dotenv-rails' # Variáveis de ambiente
end

group :test do
  gem 'webmock' # Mock HTTP requests
  gem 'vcr' # Gravar/replay HTTP interactions
  gem 'shoulda-matchers', '~> 5.0'
  gem 'database_cleaner-active_record'
  gem 'simplecov', require: false # Cobertura de código
end

group :development do
  gem 'annotate' # Adicionar schema info nos models
end
```

### 1.3 Configuração Inicial

**1.3.1 CORS (config/initializers/cors.rb)**

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3001', 'localhost:5173' # Frontend URLs
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

**1.3.2 Geocoder (config/initializers/geocoder.rb)**

```ruby
# config/initializers/geocoder.rb
Geocoder.configure(
  timeout: 5,
  lookup: :nominatim,
  use_https: true,
  
  # Nominatim (OpenStreetMap) - Grátis
  nominatim: {
    email: 'your-email@example.com' # Requerido pela política do Nominatim
  },
  
  # Cache (opcional mas recomendado)
  cache: Redis.new, # ou Rails.cache
  cache_prefix: 'geocoder:'
)
```

### 1.4 Database Model

**Migration:**

```ruby
# db/migrate/20240101000000_create_sunrise_sunset_records.rb
class CreateSunriseSunsetRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :sunrise_sunset_records do |t|
      # Localização
      t.string :location, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.date :date, null: false
      
      # Dados astronômicos
      t.string :sunrise
      t.string :sunset
      t.string :solar_noon
      t.string :day_length
      
      # Twilight periods
      t.string :civil_twilight_begin
      t.string :civil_twilight_end
      t.string :nautical_twilight_begin
      t.string :nautical_twilight_end
      t.string :astronomical_twilight_begin
      t.string :astronomical_twilight_end
      
      # Golden hours
      t.string :golden_hour
      t.string :golden_hour_end
      
      # Metadata
      t.string :timezone
      t.string :status # Para casos especiais (polar night, etc)

      t.timestamps
    end
    
    # Índices para performance
    add_index :sunrise_sunset_records, [:location, :date], unique: true
    add_index :sunrise_sunset_records, [:latitude, :longitude, :date]
    add_index :sunrise_sunset_records, :date
    add_index :sunrise_sunset_records, :created_at
  end
end
```

**Model:**

```ruby
# app/models/sunrise_sunset_record.rb
class SunriseSunsetRecord < ApplicationRecord
  # Validações
  validates :location, presence: true
  validates :latitude, presence: true, 
            numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true,
            numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :date, presence: true
  validates :location, uniqueness: { scope: :date }
  
  # Scopes
  scope :for_location, ->(location) { where(location: location) }
  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Métodos de classe
  def self.find_or_fetch(location:, start_date:, end_date:)
    existing_records = for_location(location)
                        .for_date_range(start_date, end_date)
                        .order(:date)
    
    date_range = (Date.parse(start_date)..Date.parse(end_date)).to_a
    existing_dates = existing_records.pluck(:date)
    missing_dates = date_range - existing_dates
    
    {
      existing: existing_records,
      missing_dates: missing_dates
    }
  end
  
  # Métodos de instância
  def polar_region?
    status.present? && status.include?('POLAR')
  end
  
  def to_chart_data
    {
      date: date.to_s,
      sunrise: sunrise,
      sunset: sunset,
      day_length: parse_duration(day_length)
    }
  end
  
  private
  
  def parse_duration(duration_string)
    # Converte "09:44:52" em minutos ou segundos
    return nil unless duration_string.present?
    
    parts = duration_string.split(':').map(&:to_i)
    (parts[0] * 3600) + (parts[1] * 60) + parts[2]
  end
end
```

### 1.5 Service Classes

**1.5.1 GeocodingService**

```ruby
# app/services/geocoding_service.rb
class GeocodingService
  class GeocodingError < StandardError; end
  
  def self.coordinates_for(location)
    new(location).coordinates
  end
  
  def initialize(location)
    @location = location
  end
  
  def coordinates
    return cached_coordinates if cached_coordinates.present?
    
    results = Geocoder.search(@location)
    
    if results.empty?
      raise GeocodingError, "Location '#{@location}' not found"
    end
    
    result = results.first
    
    {
      latitude: result.latitude,
      longitude: result.longitude,
      formatted_address: result.display_name || @location
    }.tap do |coords|
      cache_coordinates(coords)
    end
  rescue Geocoder::Error => e
    raise GeocodingError, "Geocoding failed: #{e.message}"
  end
  
  private
  
  def cache_key
    "geocoding:#{@location.downcase}"
  end
  
  def cached_coordinates
    Rails.cache.read(cache_key)
  end
  
  def cache_coordinates(coords)
    Rails.cache.write(cache_key, coords, expires_in: 30.days)
  end
end
```

**1.5.2 SunriseSunsetApiService**

```ruby
# app/services/sunrise_sunset_api_service.rb
class SunriseSunsetApiService
  include HTTParty
  base_uri 'https://api.sunrisesunset.io'
  
  class ApiError < StandardError; end
  class RateLimitError < ApiError; end
  class InvalidResponseError < ApiError; end
  
  def initialize(latitude:, longitude:, start_date:, end_date:, timezone: nil)
    @latitude = latitude
    @longitude = longitude
    @start_date = start_date
    @end_date = end_date
    @timezone = timezone
  end
  
  def fetch_data
    validate_date_range!
    
    response = self.class.get('/json', query: query_params, timeout: 10)
    
    handle_response(response)
  rescue HTTParty::Error, Timeout::Error => e
    raise ApiError, "API request failed: #{e.message}"
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
  
  def handle_response(response)
    unless response.success?
      raise ApiError, "API returned status #{response.code}"
    end
    
    body = response.parsed_response
    
    unless body.is_a?(Hash) && body['status'] == 'OK'
      handle_error_status(body)
    end
    
    body['results']
  rescue JSON::ParserError
    raise InvalidResponseError, 'Invalid JSON response'
  end
  
  def handle_error_status(body)
    status = body['status']
    
    case status
    when 'INVALID_REQUEST'
      raise ApiError, 'Invalid request parameters'
    when 'ZERO_RESULTS'
      # Caso especial: região polar
      return [] # Retornar array vazio ou dados especiais
    else
      raise ApiError, "API error: #{status}"
    end
  end
  
  def validate_date_range!
    start_d = Date.parse(@start_date)
    end_d = Date.parse(@end_date)
    
    if end_d < start_d
      raise ApiError, 'End date must be after start date'
    end
    
    if (end_d - start_d).to_i > 365
      raise ApiError, 'Date range cannot exceed 365 days'
    end
  rescue ArgumentError => e
    raise ApiError, "Invalid date format: #{e.message}"
  end
end
```

### 1.6 Controller

```ruby
# app/controllers/api/v1/sunrise_sunsets_controller.rb
module Api
  module V1
    class SunriseSunsetsController < ApplicationController
      rescue_from GeocodingService::GeocodingError, with: :handle_geocoding_error
      rescue_from SunriseSunsetApiService::ApiError, with: :handle_api_error
      rescue_from ActionController::ParameterMissing, with: :handle_missing_params
      
      # POST /api/v1/sunrise_sunsets
      def create
        location = params.require(:location)
        start_date = params.require(:start_date)
        end_date = params.require(:end_date)
        
        # 1. Geocode location
        coords = GeocodingService.coordinates_for(location)
        
        # 2. Check existing records
        existing_data = SunriseSunsetRecord.find_or_fetch(
          location: location,
          start_date: start_date,
          end_date: end_date
        )
        
        # 3. Fetch missing data from API
        if existing_data[:missing_dates].any?
          fetch_and_store_missing_data(
            location: location,
            coords: coords,
            missing_dates: existing_data[:missing_dates],
            start_date: start_date,
            end_date: end_date
          )
        end
        
        # 4. Return all data
        records = SunriseSunsetRecord
                    .for_location(location)
                    .for_date_range(start_date, end_date)
                    .order(:date)
        
        render json: SunriseSunsetSerializer.new(records).serializable_hash, 
               status: :ok
      end
      
      # GET /api/v1/sunrise_sunsets
      def index
        location = params[:location]
        start_date = params[:start_date]
        end_date = params[:end_date]
        
        records = SunriseSunsetRecord.all
        records = records.for_location(location) if location.present?
        records = records.for_date_range(start_date, end_date) if start_date && end_date
        records = records.order(:date).limit(1000)
        
        render json: SunriseSunsetSerializer.new(records).serializable_hash
      end
      
      private
      
      def fetch_and_store_missing_data(location:, coords:, missing_dates:, start_date:, end_date:)
        service = SunriseSunsetApiService.new(
          latitude: coords[:latitude],
          longitude: coords[:longitude],
          start_date: start_date,
          end_date: end_date
        )
        
        api_results = service.fetch_data
        
        # Criar registros para as datas faltantes
        api_results.each do |result|
          result_date = Date.parse(result['date'])
          
          next unless missing_dates.include?(result_date)
          
          SunriseSunsetRecord.create!(
            location: location,
            latitude: coords[:latitude],
            longitude: coords[:longitude],
            date: result_date,
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
            timezone: result['timezone']
          )
        end
      end
      
      def handle_geocoding_error(error)
        render json: { 
          error: {
            message: error.message,
            code: 'INVALID_LOCATION'
          }
        }, status: :unprocessable_entity
      end
      
      def handle_api_error(error)
        render json: { 
          error: {
            message: error.message,
            code: 'API_ERROR'
          }
        }, status: :bad_gateway
      end
      
      def handle_missing_params(error)
        render json: { 
          error: {
            message: "Missing required parameter: #{error.param}",
            code: 'MISSING_PARAMETER'
          }
        }, status: :bad_request
      end
    end
  end
end
```

### 1.7 Serializer

```ruby
# app/serializers/sunrise_sunset_serializer.rb
class SunriseSunsetSerializer
  include JSONAPI::Serializer
  
  attributes :location, :latitude, :longitude, :date,
             :sunrise, :sunset, :solar_noon, :day_length,
             :civil_twilight_begin, :civil_twilight_end,
             :nautical_twilight_begin, :nautical_twilight_end,
             :astronomical_twilight_begin, :astronomical_twilight_end,
             :golden_hour, :golden_hour_end,
             :timezone, :status
  
  attribute :formatted_date do |object|
    object.date.strftime('%Y-%m-%d')
  end
end
```

### 1.8 Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :sunrise_sunsets, only: [:index, :create, :show, :destroy]
    end
  end
  
  # Health check
  get '/health', to: proc { [200, {}, ['OK']] }
end
```

### 1.9 Testes (RSpec)

**spec/spec_helper.rb e rails_helper.rb** - Configuração padrão

**Model Spec:**

```ruby
# spec/models/sunrise_sunset_record_spec.rb
require 'rails_helper'

RSpec.describe SunriseSunsetRecord, type: :model do
  describe 'validations' do
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
  end
  
  describe '.find_or_fetch' do
    it 'identifies missing dates correctly' do
      # Test implementation
    end
  end
end
```

**Service Spec com WebMock:**

```ruby
# spec/services/sunrise_sunset_api_service_spec.rb
require 'rails_helper'

RSpec.describe SunriseSunsetApiService do
  let(:latitude) { 38.7223 }
  let(:longitude) { -9.1393 }
  let(:start_date) { '2024-01-01' }
  let(:end_date) { '2024-01-03' }
  
  describe '#fetch_data' do
    it 'returns sunrise/sunset data' do
      stub_request(:get, "https://api.sunrisesunset.io/json")
        .with(query: hash_including({
          lat: latitude.to_s,
          lng: longitude.to_s
        }))
        .to_return(
          status: 200,
          body: {
            status: 'OK',
            results: [
              { date: '2024-01-01', sunrise: '7:45:00 AM', sunset: '5:30:00 PM' }
            ]
          }.to_json
        )
      
      service = described_class.new(
        latitude: latitude,
        longitude: longitude,
        start_date: start_date,
        end_date: end_date
      )
      
      results = service.fetch_data
      
      expect(results).to be_an(Array)
      expect(results.first['sunrise']).to eq('7:45:00 AM')
    end
  end
end
```

---

## 2. REQUISITOS DO FRONTEND (React)

### 2.1 Setup do Projeto

```bash
# Opção 1: Vite (Recomendado - mais rápido)
npm create vite@latest sunrise-sunset-frontend -- --template react
cd sunrise-sunset-frontend
npm install

# Opção 2: Create React App
npx create-react-app sunrise-sunset-frontend
cd sunrise-sunset-frontend
```

### 2.2 Dependências Necessárias

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.0",
    "recharts": "^2.10.0",
    "date-fns": "^3.0.0",
    "react-datepicker": "^4.25.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.2.0",
    "vite": "^5.0.0",
    "eslint": "^8.55.0",
    "prettier": "^3.1.0"
  }
}
```

Instalar:

```bash
npm install axios recharts date-fns react-datepicker
```

### 2.3 Estrutura de Componentes

Veja no `PROJECT_STRUCTURE.md` para detalhes da estrutura de pastas.

### 2.4 Variáveis de Ambiente

```bash
# .env
REACT_APP_API_URL=http://localhost:3000/api/v1
```

ou para Vite:

```bash
# .env
VITE_API_URL=http://localhost:3000/api/v1
```

---

## 3. CHECKLIST DE IMPLEMENTAÇÃO

### Backend ✓
- [ ] Criar projeto Rails API
- [ ] Instalar e configurar gems
- [ ] Configurar CORS
- [ ] Criar migration e model
- [ ] Implementar GeocodingService
- [ ] Implementar SunriseSunsetApiService
- [ ] Criar controller com endpoints
- [ ] Implementar serializer
- [ ] Configurar routes
- [ ] Escrever testes (model, services, controller)
- [ ] Testar endpoints manualmente (Postman/cURL)

### Frontend ✓
- [ ] Criar projeto React
- [ ] Instalar dependências
- [ ] Configurar variáveis de ambiente
- [ ] Criar serviço de API (apiService.js)
- [ ] Criar componente LocationForm
- [ ] Criar componente DateRangePicker
- [ ] Criar componente DataChart (Recharts)
- [ ] Criar componente DataTable
- [ ] Criar componentes de feedback (Loading, Error)
- [ ] Integrar tudo no App.jsx
- [ ] Estilizar aplicação
- [ ] Testar interações

### Integração ✓
- [ ] Testar comunicação frontend-backend
- [ ] Validar tratamento de erros
- [ ] Testar casos especiais (regiões polares, datas inválidas)
- [ ] Verificar performance com múltiplas requisições

### Documentação ✓
- [ ] README principal do projeto
- [ ] README do backend
- [ ] README do frontend
- [ ] Documentação da API
- [ ] Gravar screencast demonstrando features

---

## 4. ESTIMATIVA DE TEMPO (Total: ~6 horas)

- **Setup Inicial** (Backend + Frontend): 45min
- **Backend Development**: 2h
  - Models + Services: 1h
  - Controller + Routes: 30min
  - Testes: 30min
- **Frontend Development**: 2h
  - Componentes base: 45min
  - Chart + Table: 45min
  - Styling + Polish: 30min
- **Integration & Testing**: 45min
- **Documentation + Screencast**: 30min

---

## 5. PONTOS DE ATENÇÃO

### Casos Especiais a Testar:
1. **Regiões Polares** (ex: Tromsø, Noruega no inverno)
   - Sol não nasce em alguns dias
   - API retorna valores especiais

2. **Localizações Inválidas**
   - "XYZ123" não existe
   - Tratamento de erro apropriado

3. **Rate Limiting da API**
   - Muitas requisições simultâneas
   - Implementar retry logic

4. **Datas Inválidas**
   - End_date < start_date
   - Formato incorreto
   - Range > 365 dias

### Performance:
- Usar índices no banco
- Cache de geocoding
- Batch API requests

### Segurança:
- Sanitizar inputs
- Validar parâmetros
- Rate limiting no backend (opcional)