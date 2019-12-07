require 'jwt'

module TokenHelper
  def decode_token(token)
    JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  def generate_token(user_id, wordlist_id = nil)
    secret_key = ENV['JWT_SECRET_KEY']
    JWT.encode({ exp: (Time.now + 1800).to_i, user_id: user_id, wordlist_id: wordlist_id }, secret_key, 'HS256')
  end
end
