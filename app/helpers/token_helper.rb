require 'jwt'

module TokenHelper
  def decode_token(token)
    JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  def generate_token(user_id)
    secret_key = ENV['JWT_SECRET_KEY']
    payload = if ENV['RAILS_ENV'] == 'test'
                { user_id: user_id }
              else
                { exp: (Time.now + 1800).to_i, user_id: user_id }
              end

    JWT.encode(payload, secret_key, 'HS256')
  end
end
