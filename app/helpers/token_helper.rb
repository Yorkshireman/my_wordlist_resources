require 'jwt'

module TokenHelper
  def decode_token(token)
    JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  def generate_token(payload)
    secret_key = ENV['JWT_SECRET_KEY']
    JWT.encode(payload, secret_key, 'HS256')
  end
end
