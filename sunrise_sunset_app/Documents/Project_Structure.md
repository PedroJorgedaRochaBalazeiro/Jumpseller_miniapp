# Sunrise Sunset App - Project Structure

## Overview
Full-stack application with Ruby on Rails (backend) and React (frontend) to query and visualise historical sunrise/sunset data.

## Directory Structure

```
sunrise-sunset-app/
├── backend/                      # Ruby on Rails API
│   ├── app/
│   │   ├── controllers/
│   │   │   ├── api/
│   │   │   │   └── v1/
│   │   │   │       └── sunrise_sunsets_controller.rb
│   │   │   └── application_controller.rb
│   │   ├── models/
│   │   │   └── sunrise_sunset_record.rb
│   │   ├── services/
│   │   │   ├── sunrise_sunset_api_service.rb
│   │   │   └── geocoding_service.rb
│   │   └── serializers/
│   │       └── sunrise_sunset_serializer.rb
│   ├── config/
│   │   ├── routes.rb
│   │   ├── database.yml
│   │   ├── application.rb
│   │   └── initializers/
│   │       └── cors.rb
│   ├── db/
│   │   ├── migrate/
│   │   │   └── 001_create_sunrise_sunset_records.rb
│   │   ├── schema.rb
│   │   └── seeds.rb
│   ├── spec/                     # Tests RSpec
│   │   ├── controllers/
│   │   │   └── api/
│   │   │       └── v1/
│   │   │           └── sunrise_sunsets_controller_spec.rb
│   │   ├── services/
│   │   │   ├── sunrise_sunset_api_service_spec.rb
│   │   │   └── geocoding_service_spec.rb
│   │   ├── models/
│   │   │   └── sunrise_sunset_record_spec.rb
│   │   └── spec_helper.rb
│   ├── Gemfile
│   ├── Gemfile.lock
│   ├── Rakefile
│   └── README.md
│
├── frontend/                     # React App
│   ├── public/
│   │   ├── index.html
│   │   └── favicon.ico
│   ├── src/
│   │   ├── components/
│   │   │   ├── LocationForm.jsx
│   │   │   ├── DateRangePicker.jsx
│   │   │   ├── DataChart.jsx
│   │   │   ├── DataTable.jsx
│   │   │   ├── ErrorMessage.jsx
│   │   │   └── LoadingSpinner.jsx
│   │   ├── services/
│   │   │   └── apiService.js
│   │   ├── utils/
│   │   │   ├── dateHelpers.js
│   │   │   └── chartConfig.js
│   │   ├── hooks/
│   │   │   └── useSunriseSunsetData.js
│   │   ├── App.jsx
│   │   ├── App.css
│   │   ├── index.js
│   │   └── index.css
│   ├── package.json
│   ├── package-lock.json
│   └── README.md
│
├── docker-compose.yml            # Optional: Docker configuration
├── .gitignore
└── README.md                     # Principal project README
```

## Tecnologias e Dependências

### Backend (Ruby on Rails)

**Gems Principais:**
- `rails` (~> 7.1) - Framework web
- `pg` ou `sqlite3` - Database
- `rack-cors` - CORS handling
- `httparty` - HTTP requests para API externa
- `geocoder` - Conversão de nomes de cidades para coordenadas
- `fast_jsonapi` ou `active_model_serializers` - JSON serialization

**Gems de Desenvolvimento/Teste:**
- `rspec-rails` - Framework de testes
- `factory_bot_rails` - Test fixtures
- `faker` - Dados fake para testes
- `webmock` - Mock HTTP requests
- `shoulda-matchers` - Matchers para testes
- `database_cleaner-active_record` - Limpeza de DB nos testes
- `simplecov` - Cobertura de código

### Frontend (React)

**Dependências Principais:**
- `react` (^18.x)
- `react-dom`
- `axios` - HTTP client
- `recharts` ou `chart.js` com `react-chartjs-2` - Visualização de dados
- `date-fns` ou `dayjs` - Manipulação de datas
- `react-datepicker` - Seletor de datas

**Dependências de Desenvolvimento:**
- `@vitejs/plugin-react` ou `react-scripts` - Build tools
- `eslint` - Linting
- `prettier` - Code formatting

## Modelo de Dados

### Tabela: `sunrise_sunset_records`

```ruby
create_table :sunrise_sunset_records do |t|
  t.string :location, null: false          # Nome da localização (ex: "Lisbon")
  t.decimal :latitude, precision: 10, scale: 6, null: false
  t.decimal :longitude, precision: 10, scale: 6, null: false
  t.date :date, null: false
  
  # Dados do nascer/pôr do sol
  t.string :sunrise                        # Ex: "6:30:00 AM"
  t.string :sunset                         # Ex: "8:45:00 PM"
  t.string :solar_noon
  t.string :day_length
  t.string :civil_twilight_begin
  t.string :civil_twilight_end
  t.string :nautical_twilight_begin
  t.string :nautical_twilight_end
  t.string :astronomical_twilight_begin
  t.string :astronomical_twilight_end
  t.string :golden_hour                    # Golden hour (manhã)
  t.string :golden_hour_end                # Golden hour (tarde)
  
  t.string :timezone                       # Ex: "Europe/Lisbon"
  
  t.timestamps
end

# Índices para otimização
add_index :sunrise_sunset_records, [:location, :date], unique: true
add_index :sunrise_sunset_records, [:latitude, :longitude, :date]
add_index :sunrise_sunset_records, :date
```

## Fluxo de Dados

### 1. Requisição do Frontend
```javascript
POST /api/v1/sunrise_sunsets
{
  "location": "Lisbon",
  "start_date": "2024-01-01",
  "end_date": "2024-01-31"
}
```

### 2. Processamento no Backend

1. **Controller** recebe a requisição
2. **GeocodingService** converte "Lisbon" → coordenadas (lat/lng)
3. **Controller** verifica dados existentes no DB
4. Para datas faltantes:
   - **SunriseSunsetApiService** faz chamada à API externa
   - Salva novos registros no DB
5. Retorna todos os dados (cache + novos)

### 3. Resposta para Frontend
```javascript
{
  "data": [
    {
      "id": "1",
      "type": "sunrise_sunset_record",
      "attributes": {
        "location": "Lisbon",
        "date": "2024-01-01",
        "sunrise": "7:45:23 AM",
        "sunset": "5:30:15 PM",
        "golden_hour": "6:15:00 AM",
        "golden_hour_end": "6:15:00 PM",
        "day_length": "09:44:52"
      }
    },
    // ... mais registros
  ]
}
```

## Endpoints da API

### Backend Rails API

```
GET    /api/v1/sunrise_sunsets         # Lista registros (com filtros)
POST   /api/v1/sunrise_sunsets         # Cria/obtém dados para range
GET    /api/v1/sunrise_sunsets/:id     # Mostra registro específico
DELETE /api/v1/sunrise_sunsets/:id     # Deleta registro
```

**Parâmetros de Query:**
- `location` (string) - Nome da cidade
- `start_date` (date) - Data inicial (YYYY-MM-DD)
- `end_date` (date) - Data final (YYYY-MM-DD)
- `latitude` (decimal) - Opcional, se não fornecer location
- `longitude` (decimal) - Opcional, se não fornecer location

## API Externa (SunriseSunset.io)

**Base URL:** `https://api.sunrisesunset.io/json`

**Parâmetros:**
- `lat` - Latitude (obrigatório)
- `lng` - Longitude (obrigatório)
- `date_start` - Data inicial (YYYY-MM-DD)
- `date_end` - Data final (YYYY-MM-DD)
- `timezone` - Timezone (opcional)

**Exemplo de Request:**
```
GET https://api.sunrisesunset.io/json?lat=38.7223&lng=-9.1393&date_start=2024-01-01&date_end=2024-01-31
```

**Exemplo de Response:**
```json
{
  "results": [
    {
      "date": "2024-01-01",
      "sunrise": "7:45:23 AM",
      "sunset": "5:30:15 PM",
      "solar_noon": "12:37:49 PM",
      "day_length": "09:44:52",
      "civil_twilight_begin": "7:15:00 AM",
      "civil_twilight_end": "6:00:38 PM",
      "nautical_twilight_begin": "6:40:31 AM",
      "nautical_twilight_end": "6:35:07 PM",
      "astronomical_twilight_begin": "6:06:53 AM",
      "astronomical_twilight_end": "7:08:45 PM",
      "golden_hour": "6:15:00 AM",
      "golden_hour_end": "6:15:00 PM"
    }
  ],
  "status": "OK"
}
```

## Tratamento de Erros

### Erros a Serem Tratados:

1. **Localização Inválida**
   - Location não encontrada pelo geocoder
   - Coordenadas fora dos limites (-90 a 90 lat, -180 a 180 lng)

2. **Parâmetros Faltantes**
   - Location ou coordenadas não fornecidas
   - Datas inválidas ou faltantes

3. **Casos Especiais Ártico/Antártico**
   - API retorna status especial quando sol não nasce/põe
   - Armazenar com valores especiais (ex: "N/A" ou "POLAR_NIGHT"/"MIDNIGHT_SUN")

4. **Falhas na API Externa**
   - Timeout
   - Rate limiting
   - Serviço indisponível
   - Response inválido

5. **Erros de Database**
   - Constraint violations
   - Connection errors

### Estrutura de Erro do Backend:

```json
{
  "error": {
    "message": "Location not found",
    "code": "INVALID_LOCATION",
    "details": "Could not geocode 'InvalidCity'"
  }
}
```

## Otimizações Implementadas

1. **Caching em Database**
   - Evita chamadas desnecessárias à API externa
   - Índices para busca rápida

2. **Batch Requests**
   - API externa suporta date_start e date_end
   - Uma única chamada para múltiplas datas

3. **Geocoding Cache**
   - Armazena lat/lng das localizações consultadas
   - Evita geocoding repetido

4. **Frontend Optimizations**
   - Debounce em inputs
   - Loading states
   - Error boundaries

## Testes

### Backend (RSpec)

**Controller Tests:**
- Request specs para todos os endpoints
- Validação de parâmetros
- Tratamento de erros

**Service Tests:**
- SunriseSunsetApiService com WebMock
- GeocodingService
- Edge cases (polar regions, invalid data)

**Model Tests:**
- Validações
- Associations
- Scopes

### Frontend (Jest/React Testing Library)

- Componentes isolados
- Integração com API
- User interactions
- Error states

## Variáveis de Ambiente

### Backend (.env)

```
DATABASE_URL=postgresql://user:password@localhost/sunrise_db
RAILS_ENV=development
GEOCODER_API_KEY=your_api_key_here  # Se usar geocoder pago
```

### Frontend (.env)

```
REACT_APP_API_URL=http://localhost:3000/api/v1
```

## Comandos de Setup

### Backend

```bash
cd backend
bundle install
rails db:create db:migrate
rails db:seed  # Opcional: dados de exemplo
rails server -p 3000
```

### Frontend

```bash
cd frontend
npm install
npm start  # Roda na porta 3001 ou similar
```

### Testes

```bash
# Backend
cd backend
bundle exec rspec

# Frontend
cd frontend
npm test
```

## Próximos Passos para Implementação

1. **Setup Inicial**
   - Criar projeto Rails (API only)
   - Criar projeto React (Vite ou CRA)
   - Configurar CORS

2. **Backend Development**
   - Migration e Model
   - Services (API + Geocoding)
   - Controller e Routes
   - Testes

3. **Frontend Development**
   - Componentes base
   - API integration
   - Charts e Tables
   - Styling

4. **Integration & Testing**
   - End-to-end testing
   - Error handling
   - Edge cases

5. **Documentation**
   - README completo
   - API documentation
   - Screencast

## Bibliotecas de Charts Recomendadas

### Option 1: Recharts (Recomendado)
- Mais React-friendly
- Boa documentação
- Sintaxe declarativa

### Option 2: Chart.js com react-chartjs-2
- Mais features
- Melhor performance com grandes datasets
- Mais customizável

### Tipos de Charts Úteis:
- **Line Chart** - Evolução de sunrise/sunset ao longo do tempo
- **Bar Chart** - Comparação de day_length
- **Area Chart** - Golden hour periods