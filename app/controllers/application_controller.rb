class ApplicationController < ActionController::API
  before_action :set_headers

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end

  rescue_from 'ActionController::ParameterMissing' do |e|
    render_error_response(400, e)
  end

  rescue_from 'ActiveRecord::RecordNotFound' do |e|
    render_error_response(404, e)
  end

  rescue_from 'JWT::DecodeError' do |e|
    render_error_response(400, e)
  end

  private

  def render_error_response(status, message)
    response.status = status
    render json: {
      errors: [
        { title: message }
      ]
    }
  end
end
