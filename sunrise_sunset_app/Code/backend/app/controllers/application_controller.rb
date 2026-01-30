# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  # Global exception handling
  rescue_from StandardError, with: :handle_standard_error if Rails.env.production?
  
  private
  
  def handle_standard_error(error)
    Rails.logger.error("Unhandled error: #{error.class} - #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))
    
    render json: {
      error: {
        message: "An unexpected error occurred",
        code: 'INTERNAL_ERROR'
      }
    }, status: :internal_server_error
  end
end