require_relative '../helpers/token_helper'

class ApplicationController < ActionController::API
  before_action :parse_user_id_from_authorization_header
  after_action :set_headers

  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end

  rescue_from 'ActionController::BadRequest' do |e|
    render_error_response(400, e)
  end

  rescue_from 'ActionController::ParameterMissing' do |e|
    render_error_response(400, e)
  end

  rescue_from 'ActiveRecord::RecordInvalid' do |e|
    render_error_response(422, e)
  end

  rescue_from 'ActiveRecord::RecordNotFound' do |e|
    render_error_response(404, e)
  end

  rescue_from 'ActiveRecord::RecordNotUnique' do
    render_error_response(422, 'id is not unique')
  end

  rescue_from 'JWT::DecodeError' do |e|
    render_error_response(400, e)
  end

  rescue_from 'JWT::ExpiredSignature' do |e|
    render_error_response(401, e)
  end

  private

  def parse_user_id_from_authorization_header
    raise(ActionController::BadRequest.new, 'missing Authorization header') unless request.headers['Authorization']

    @user_id = parse_token_from_headers(request.headers).then do |token|
      parse_user_id_from_token(token) || raise(ActionController::BadRequest.new, 'Invalid token')
    end
  end

  def parse_token_from_headers(headers)
    headers['Authorization'].split(' ').last
  end

  def parse_user_id_from_token(token)
    decode_token(token)[0]['user_id']
  end

  def render_error_response(status, message)
    response.status = status
    render json: {
      errors: [
        { title: message }
      ]
    }
  end
end
