# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :sunrise_sunsets, only: [:index, :create, :show, :destroy]
    end
  end
  
  # Health check endpoint
  get '/health', to: proc { 
    [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok', timestamp: Time.now.iso8601 }.to_json]] 
  }
  
  # API documentation endpoint (optional)
  get '/api', to: proc {
    [200, { 'Content-Type' => 'application/json' }, [{
      version: 'v1',
      endpoints: {
        health: '/health',
        sunrise_sunsets: {
          index: 'GET /api/v1/sunrise_sunsets',
          create: 'POST /api/v1/sunrise_sunsets',
          show: 'GET /api/v1/sunrise_sunsets/:id',
          destroy: 'DELETE /api/v1/sunrise_sunsets/:id'
        }
      }
    }.to_json]]
  }
end