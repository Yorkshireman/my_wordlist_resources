require 'jwt'

module TokenHelper
  def decode_token(token)
    JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
  end

  def generate_token(user_id, wordlist_id = nil)
    secret_key = ENV['JWT_SECRET_KEY']
    time_now = ENV['RAILS_ENV'] == 'test' ? 1_590_331_503 : Time.now
    JWT.encode({ exp: (time_now + 1800).to_i, user_id: user_id, wordlist_id: wordlist_id }, secret_key, 'HS256')
  end
end
