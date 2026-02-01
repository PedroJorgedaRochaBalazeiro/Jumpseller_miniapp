# 🌅 Sunrise Sunset App

Full-stack application for consulting and viewing historical sunrise and sunset data for different locations, using the SunriseSunset.io API.

## 📋 Index

- [About the Project](#about-the-project)
- [Technologies Used](#technologies-used)
- [Features](#features)
- [Project Structure](#project-structure)
- [Installation and Configuration](#installation-and-configuration)
- [How to Use](#how-to-use)
- [API Endpoints](#api-endpoints)
- [Testing](#testing)
- [Design Decisions](#design-decisions)
- [Future Improvements](#future-improvements)

## 🎯 About the Project

This project was developed as a case study to demonstrate full-stack development skills, integrating:

- **Backend**: Ruby on Rails API to manage data and communication with external API
- **Frontend**: React for interactive user interface
- **External API**: SunriseSunset.io to obtain astronomical data

### Main Features:

1. ✅ Search for sunrise/sunset data by location and date range
2. ✅ Intelligent database caching to avoid unnecessary API calls
3. ✅ Automatic geocoding of city names
4. ✅ Visualisation in charts and tables
5. ✅ Robust error handling (invalid locations, polar regions, etc.)
6. ✅ Automated testing

## 🚀 Technologies Used

### Backend
- **Ruby** 3.2+
- **Ruby on Rails** 7.1+ (API mode)
- **PostgreSQL** (Database)
- **HTTParty** (HTTP client)
- **Geocoder** (geocoding service)
- **RSpec** (testing)

### Frontend
- **React** 18+
- **Axios** (HTTP client)
- **Recharts** (data visualisation)
- **React DatePicker** (date selection)
- **date-fns** (date utilities)

### External APIs
- [SunriseSunset.io API](https://sunrisesunset.io/api/) - Sunrise/sunset data
- Nominatim (OpenStreetMap) - Geocoding

## ✨ Features

### Implemented Optimisations:

1. **Database cache**: Data that has already been queried is stored locally
2. **Batch requests**: A single call for multiple dates (up to 365 days)
3. **Geocoding cache**: location coordinates are cached
4. **Smart Data Fetching**: only searches for data that does not exist in the cache

### Handling special cases:

- ❄️ **Polar regions**: days when the sun does not rise or set
- 🗺️ **Invalid locations**: Clear feedback when the city is not found
- 📅 **Date validation**: Checks for invalid ranges and formats
- 🔄 **API failures**: Retry logic and descriptive error messages

## 📁 Project structure

See Documents

## 🛠️ Installation and Configuration

### Prerequisites

- Ruby 3.2+ and Rails 7.1+
- Node.js 18+ and npm
- PostgreSQL (or SQLite for development)
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/seu-usuario/sunrise-sunset-app.git
cd sunrise-sunset-app
```

### 2. Set Up Backend

```bash
cd backend

# Install dependencies
bundle install

# Configure database
cp config/database.yml.example config/database.yml
# Edit config/database.yml with your credentials

# Create and configure database
rails db:create
rails db:migrate

# (Optional) Populate with sample data
rails db:seed

# Start server (port 3000)
rails server
```

**Environment configuration (backend/.env):**

```env
DATABASE_URL=postgresql://user:password@localhost/sunrise_db
RAILS_ENV=development
GEOCODER_EMAIL=your-email@example.com
```

### 3. Frontend Setup

```bash
cd ../frontend

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env
# VITE_API_URL=http://localhost:3000/api/v1

# Start development server (port 5173 or 3001)
npm run dev
```

### 4. Verify Installation

- Backend: http://localhost:3000/health
- Frontend: http://localhost:5173 (or indicated port)

## 💻 How to Use

### Web Interface:

1. **Enter a Location**: E.g. ‘Lisbon,’ ‘Berlin,’ ‘Tokyo’
2. **Select Date Range**: Start and end date (max. 365 days)
3. **Click on ‘Get Sunrise & Sunset Data’**
4. **View the Results**:
   - Line graph showing evolution over time
   - Detailed table with all data


## 📡 API Endpoints

### POST /api/v1/sunrise_sunsets

Searches for or creates sunrise/sunset records for a location and date range.

**Request Body:**
```json
{
  "location": "Lisbon",
  "start_date": "2024-01-01",
  "end_date": "2024-01-31"
}
```

**Response (200 OK):**
```json
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
        "day_length": "09:44:52",
        "solar_noon": "12:37:49 PM"
      }
    }
  ]
}
```

**Error Responses:**

- `400 Bad Request`: Missing or invalid parameters
- `422 Unprocessable Entity`: Location not found
- `502 Bad Gateway`: External API failure

### GET /api/v1/sunrise_sunsets

List existing records (with optional filters).

**Query Parameters:**
- `location` (string, optional)
- `start_date` (date, optional)
- `end_date` (date, optional)

## 🧪 Tests

### Backend Tests (RSpec)

```bash
cd backend

# Run all tests
bundle exec rspec

# Run specific tests
bundle exec rspec spec/models/sunrise_sunset_record_spec.rb
bundle exec rspec spec/services/

# With code coverage
COVERAGE=true bundle exec rspec
```

**Test Coverage:**
- Models: Validations, scopes, methods
- Services: Integration with external APIs (with WebMock)
- Controllers: Request specs for all endpoints
- Edge cases: Polar regions, API errors, validations

### Frontend Tests

```bash
cd frontend

# Run tests
npm test

# With coverage
npm test -- --coverage
```

## 🎨 Design Decisions

### Backend:

1. **Rails API Mode**: Lighter, focused on JSON API
2. **Service Objects**: Business logic separated from controllers
3. **Database Caching**: Avoids external API costs and latency
4. **Local Geocoding**: Uses Nominatim (free) instead of Google Maps API
5. **JSONAPI Serialiser**: Consistent response format

### Frontend:

1. **Recharts**: Declarative and React-friendly library for charts
2. **Axios**: More robust HTTP client than fetch
3. **date-fns**: Lighter than Moment.js
4. **Component Composition**: Small, reusable components

### Database Schema:

- Compound indexes for optimised queries
- String storage for teams (flexibility with formats)
- `status` field for special cases (polar night, etc.)

## 🔮 Future Improvements

### Short Term:
- [ ] Add E2E tests (Cypress)
- [ ] Implement dark mode
- [ ] Export to CSV/PDF
- [ ] Side-by-side comparison of locations

### Medium Term:
- [ ] Background jobs with Sidekiq for asynchronous fetching
- [ ] WebSockets for real-time updates
- [ ] Cache with Redis
- [ ] Rate limiting on the backend

### Long Term:
- [ ] User authentication system
- [ ] Favourites and search history
- [ ] Golden hour notifications
- [ ] Mobile app (React Native)

## 📝 Additional Documentation

- [Detailed Project Structure](./PROJECT_STRUCTURE.md)
- [Complete Requirements Guide](./REQUIREMENTS_GUIDE.md)
- [API Documentation](./docs/API_DOCUMENTATION.md)

## 🤝 Contributions

This is a demo project, but contributions are welcome!

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m “Add some AmazingFeature”`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 Licence

This project is free for educational and demonstration purposes.

## 👤 Author

Developed as a case study for Jumpseller

## 🙏 Acknowledgements

- [SunriseSunset.io](https://sunrisesunset.io) for the free API
- [Nominatim/OpenStreetMap](https://nominatim.org) for the geocoding service
- Ruby on Rails and React communities

---

**⚡ Quick Start:**

```bash
# Backend
cd backend && bundle install && rails db:setup && rails server

# Frontend (new window)
cd frontend && npm install && npm run dev
```

Access: http://localhost:5173