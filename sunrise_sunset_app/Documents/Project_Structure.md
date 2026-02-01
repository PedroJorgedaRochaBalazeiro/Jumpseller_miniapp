# Sunrise Sunset App - Project Structure

## Overview
Full-stack application with Ruby on Rails (backend) and React (frontend) to query and visualise historical sunrise/sunset data.

## Directory Structure

```
sunrise-sunset-app/Code/
├── backend/                      # Ruby on Rails API (Check backend README)
│
├── frontend/                     # React App (Check frontend README)
│
├── docker-compose.yml            # Optional: Docker configuration
├── .gitignore
└── README.md                     # Principal project README
```

## Technologies and Dependencies

### Backend (Ruby on Rails)

**Main Gems:**
- `rails` (~> 7.1) - Web framework
- `pg` or `sqlite3` - Database
- `rack-cors` - CORS handling
- `httparty` - HTTP requests for external API
- `geocoder` - Conversion of city names to coordinates
- `fast_jsonapi` or `active_model_serializers` - JSON serialisation

**Development/Testing Gems:**
- `rspec-rails` - Testing framework
- `factory_bot_rails` - Test fixtures
- `faker` - Fake data for testing
- `webmock` - Mock HTTP requests
- `shoulda-matchers` - Matchers for testing
- `database_cleaner-active_record` - DB cleaning in tests
- `simplecov` - Code coverage

### Frontend (React)

**Main Dependencies:**
- `react` (^18.x)
- `react-dom`
- `axios` - HTTP client
- `recharts` or `chart.js` with `react-chartjs-2` - Data visualisation
- `date-fns` or `dayjs` - Date manipulation
- `react-datepicker` - Date picker

**Development Dependencies:**
- `@vitejs/plugin-react` or `react-scripts` - Build tools
- `eslint` - Linting
- `prettier` - Code formatting

## Data Model

Table: `sunrise_sunset_records`

```ruby
create_table :sunrise_sunset_records do |t|
  t.string :location, null: false          # Location name (e.g., ‘Lisbon’)
  t.decimal :latitude, precision: 10, scale: 6, null: false
  t.decimal :longitude, precision: 10, scale: 6, null: false
  t.date :date, null: false
  
  # Sunrise/sunset data
  t.string :sunrise                        # E.g. ‘6:30:00 AM’
  t.string :sunset                         # E.g. ‘8:45:00 PM’
  t.string :solar_noon
  t.string :day_length
  t.string :civil_twilight_begin
  t.string :civil_twilight_end
  t.string :nautical_twilight_begin
  t.string :nautical_twilight_end
  t.string :astronomical_twilight_begin
  t.string :astronomical_twilight_end
  t.string :golden_hour                    # Golden hour (morning)
  t.string :golden_hour_end                # Golden hour (afternoon)
  
  t.string :timezone                       # Ex: ‘Europe/Lisbon’
  
  t.timestamps
end

# Indexes for optimisation
add_index :sunrise_sunset_records, [:location, :date], unique: true
add_index :sunrise_sunset_records, [:latitude, :longitude, :date]
add_index :sunrise_sunset_records, :date
```

## Data Flow

### 1. Frontend Request
```javascript
POST /api/v1/sunrise_sunsets
{
  ‘location’: ‘Lisbon’,
  ‘start_date’: ‘2024-01-01’,
  ‘end_date’: ‘2024-01-31’
}
```

### 2. Backend Processing

1. **Controller** receives the request
2. **GeocodingService** converts ‘Lisbon’ → coordinates (lat/lng)
3. **Controller** checks existing data in the DB
4. For missing dates:
   - **SunriseSunsetApiService** calls the external API
   - Saves new records in the DB
5. Returns all data (cache + new)

### 3. Response to Frontend
```javascript
{
  ‘data’: [
    {
      ‘id’: ‘1’,
      ‘type’: ‘sunrise_sunset_record’,
      ‘attributes’: {
        ‘location’: ‘Lisbon’,
        ‘date’: ‘2024-01-01’,
        ‘sunrise’: ‘7:45:23 AM’,
        ‘sunset’: ‘5:30:15 PM’,
        ‘golden_hour’: ‘6:15:00 AM’,
        ‘golden_hour_end’: ‘6:15:00 PM’,
        ‘day_length’: ‘09:44:52’
      }
    },
    // ... more records
  ]
}
```

## API Endpoints

### Backend Rails API

```
GET    /api/v1/sunrise_sunsets         # List records (with filters)
POST   /api/v1/sunrise_sunsets         # Create/get data for range
GET    /api/v1/sunrise_sunsets/:id     # Show specific record
DELETE /api/v1/sunrise_sunsets/:id     # Delete record
```

**Query Parameters:**
- `location` (string) - City name
- `start_date` (date) - Start date (YYYY-MM-DD)
- `end_date` (date) - End date (YYYY-MM-DD)
- `latitude` (decimal) - Optional, if location is not provided
- `longitude` (decimal) - Optional, if location is not provided

## External API (SunriseSunset.io)

**Base URL:** `https://api.sunrisesunset.io/json`

**Parameters:**
- `lat` - Latitude (required)
- `lng` - Longitude (required)
- `date_start` - Start date (YYYY-MM-DD)
- `date_end` - End date (YYYY-MM-DD)
- `timezone` - Timezone (optional)

**Request example:**
```
GET https://api.sunrisesunset.io/json?lat=38.7223&lng=-9.1393&date_start=2024-01-01&date_end=2024-01-31
```

**Response example:**
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

## Error Handling

### Errors to be Handled:

1. **Invalid Location**
   - Location not found by geocoder
   - Coordinates outside limits (-90 to 90 lat, -180 to 180 lng)

2. **Missing Parameters**
   - Location or coordinates not provided
   - Invalid or missing dates

3. **Arctic/Antarctic Special Cases**
   - API returns special status when sun does not rise/set
   - Store with special values (e.g., ‘N/A’ or “POLAR_NIGHT”/‘MIDNIGHT_SUN’)

4. **External API Failures**
   - Timeout
   - Rate limiting
   - Service unavailable
   - Invalid response

5. **Database Errors**
   - Constraint violations
   - Connection errors

### Backend Error Structure:

```json
{
  "error": {
    "message": "Location not found",
    "code": "INVALID_LOCATION",
    "details": "Could not geocode 'InvalidCity'"
  }
}
```

## Implemented Optimisations

1. **Database Caching**
   - Prevents unnecessary calls to the external API
   - Indexes for fast searching

2. **Batch Requests**
   - External API supports date_start and date_end
   - A single call for multiple dates

3. **Geocoding Cache**
   - Stores lat/lng of queried locations
   - Prevents repeated geocoding

4. **Frontend Optimisations**
   - Debounce on inputs
   - Loading states
   - Error boundaries

## Testes

### Backend (RSpec)

**Controller Tests:**
- Request specs for all endpoints
- Parameter validation
- Error handling

**Service Tests:**
- SunriseSunsetApiService with WebMock
- GeocodingService
- Edge cases (polar regions, invalid data)

**Model Tests:**
- Validations
- Associations
- Scopes

### Frontend (Jest/React Testing Library)

- Isolated components
- API integration
- User interactions
- Error states

## Environment Variables

### Backend (.env)

```
DATABASE_URL=postgresql://user:password@localhost/sunrise_db
RAILS_ENV=development
GEOCODER_API_KEY=your_api_key_here  # If using paid geocoder
```

### Frontend (.env)

```
REACT_APP_API_URL=http://localhost:3000/api/v1
```

### Frontend (.env)

```
REACT_APP_API_URL=http://localhost:3000/api/v1
```

## Setup Commands

### Backend

```bash
cd backend
bundle install
rails db:create db:migrate
rails db:seed  # Optional: sample data
rails server -p 3000
```

### Frontend

```bash
cd frontend
npm install
npm start  # Runs on port 3001 or similar
```

### Tests

```bash
# Backend
cd backend
bundle exec rspec

# Frontend
cd frontend
npm test
```

## Next Steps for Implementation

1. **Initial Setup**
   - Create Rails project (API only)
   - Create React project (Vite or CRA)
   - Configure CORS

2. **Backend Development**
   - Migration and Model
   - Services (API + Geocoding)
   - Controller and Routes
   - Testing

3. **Frontend Development**
   - Base components
   - API integration
   - Charts and Tables
   - Styling

4. **Integration & Testing**
   - End-to-end testing
   - Error handling
   - Edge cases

5. **Documentation**
   - Complete README
   - API documentation
   - Screencast

## Recommended Chart Libraries

### Option 1: Recharts (Recommended)
- More React-friendly
- Good documentation
- Declarative syntax

### Option 2: Chart.js with react-chartjs-2
- More features
- Better performance with large datasets
- More customisable

### Useful Chart Types:
- **Line Chart** - Sunrise/sunset evolution over time
- **Bar Chart** - Day_length comparison
- **Area Chart** - Golden hour periods