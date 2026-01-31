# 🚀 Quick Start Guide - Backend

## Prerequisites

Before you begin, ensure you have installed:

- **Ruby 3.2.0+**: `ruby -v`. Version used: 3.4.8
- **Bundler**: `gem install bundler`. Version used: 4.0.5
- **PostgreSQL 12+**: `psql --version` (or SQLite3 for development). Version used: 18.1
- **Git**: `git --version`. Version used: 2.52.0.windows.1.

## Quick Setup (5 minutes)

### Option 1: Automatic Script

```bash
cd backend
chmod +x setup.sh
./setup.sh
```

### Option 2: Manual Setup

```bash
# 1. Enter the directory
cd backend

# 2. Install dependencies
bundle install

# 3. Configure environment variables
cp .env.example .env
# Edit .env with your settings

# 4. Configure database
# For PostgreSQL - edit config/database.yml
# Or keep SQLite3 (default for development)

# 5. Create and configure database
rails db:create
rails db:migrate

# 6. (Optional) Populate with sample data
rails db:seed

# 7. Start server
rails server
```

## ✅ Verify Installation

### 1. Health Check

```bash
curl http://localhost:3000/health
```

**Expected response:**
```json
{
  "status": "ok",
  "timestamp":"2026-01-31T22:22:33+00:00"
}
```

### 2. Test API - Test with cmd

```bash
curl -X POST http://localhost:3000/api/v1/sunrise_sunsets -H "Content-Type: application/json" -d "{\"location\":\"Lisbon\",\"start_date\":\"2024-01-01\",\"end_date\":\"2024-01-03\"}"
```

### 3. Run Tests

```bash
bundle exec rspec
```

**Expected output:**
```
Finished in X seconds
XX examples, 0 failures
```

## 🔧 Detailed Configuration

### Database (PostgreSQL)

If you are using PostgreSQL, edit `config/database.yml`:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: sunrise_sunset_development
  pool: 5
  username: your_username (example:postgres)
  password: your_password (example:postgres)
  host: localhost
```

### Database (SQLite - Simpler)

To use SQLite in development, edit the `Gemfile`:

```ruby
# Replace this line:
gem “pg”, “~> 1.5”

# With this:
gem “sqlite3”, “~> 1.4”
```

Then:
```bash
bundle install
rails db:create db:migrate
```

### Environment Variables

Edit the `.env` file:

```env
# Email for the geocoding service (Nominatim)
GEOCODER_EMAIL=seu-email@example.com

# Environment
RAILS_ENV=development
```

## 📦 File Structure Created

```
backend/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── api/v1/
│   │       └── sunrise_sunsets_controller.rb
│   ├── models/
│   │   └── sunrise_sunset_record.rb
│   ├── services/
│   │   ├── geocoding_service.rb
│   │   └── sunrise_sunset_api_service.rb
│   └── serializers/
│       └── sunrise_sunset_serializer.rb
├── config/
│   ├── database.yml
│   ├── routes.rb
│   └── initializers/
│       ├── cors.rb
│       └── geocoder.rb
├── db/
│   ├── migrate/
│   │   └── 20240101000000_create_sunrise_sunset_records.rb
│   └── seeds.rb
├── spec/
│   ├── controllers/
│   ├── models/
│   ├── services/
│   ├── factories/
│   ├── rails_helper.rb
│   └── spec_helper.rb
├── Gemfile
├── README.md
├── .env.example
├── .gitignore
└── setup.sh
```

## 🎯 Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-----------|
| GET | `/health` | Health check |
| POST | `/api/v1/sunrise_sunsets` | Create/retrieve data |
| GET | `/api/v1/sunrise_sunsets` | List records |
| GET | `/api/v1/sunrise_sunsets/:id` | Show record |
| DELETE | `/api/v1/sunrise_sunsets/:id` | Delete record |

## 🧪 Executar Testes

```bash
# All tests
bundle exec rspec

# Models only
bundle exec rspec spec/models

# Services only
bundle exec rspec spec/services

# Controllers only
bundle exec rspec spec/controllers

# With coverage
COVERAGE=true bundle exec rspec
```

## 🐛 Troubleshooting

### Error: ‘Database does not exist’

```bash
rails db:create
```

### Error: ‘Pending migrations’

```bash
rails db:migrate
```

### Error: ‘LoadError: cannot load such file -- pg’

**Solution 1**: Install PostgreSQL
```bash
# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib libpq-dev

# Mac
brew install postgresql
```

**Solution 2**: Use SQLite (simpler)
```ruby
# In Gemfile, replace:
gem “pg” 
# with:
gem “sqlite3”
```

### Error: Port 3000 is already in use

```bash
# Find process
lsof -ti:3000

# Kill process
kill -9 $(lsof -ti:3000)

# Or use another port
rails server -p 3001
```

### Error: ‘Geocoder::OverQueryLimitError’

The Nominatim service has a limit of 1 request per second. The cache should prevent this, but if it occurs:
- Wait a few seconds
- Check that the email is configured in .env

## 📊 Test Data

The `db/seeds.rb` file creates sample data for:
- **Lisbon, Berlin, Tokyo**
- **Last 7 days**

To populate:
```bash
rails db:seed
```

To clear and repopulate:
```bash
rails db:reset
```

## 🔄 Development Workflow

1. **Make changes to the code**
2. **Run tests**: `bundle exec rspec`
3. **Test manually**: Use Postman or curl
4. **Check logs**: `tail -f log/development.log`
5. **Commit**: `git add . && git commit -m ‘your message’`

## 📝 Useful Commands

```bash
# Rails console
rails console

# Available routes
rails routes

# Database status
rails db:version

# Revert last migration
rails db:rollback

# View logs in real time
tail -f log/development.log

# Clear cache
rails cache:clear

# Code analysis
bundle exec rubocop
```

## 🎓 Next Steps

1. ✅ Backend is running
2. → Develop Frontend (React)
3. → Integrate Frontend with Backend
4. → Test complete application
5. → Create documentation
6. → Record screencast

## 💡 Tips

- **Always run tests** before committing
- **Use the Rails console** to test queries and services
- **Monitor logs** during development
- **Cache works**: Second request to the same location is instantaneous
- **External API is free** but has rate limits

## 🆘 Need help?

- Check the complete `README.md` in the backend directory
- Read the comments in the code
- Run `rails console` and test interactively
- Review the tests in `spec/` to see usage examples

## 🎉 Done!

If the health check worked, the backend is ready to use!

```bash
curl http://localhost:3000/health
# {‘status’:‘ok’,“timestamp”:‘...’}
```

Now you can:
1. Test the endpoints with Postman/curl
2. Begin frontend development
3. Connect the frontend to the backend

---

**Backend successfully created! 🚀**