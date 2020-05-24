require 'jwt'

module TokenHelper
  def decode_token(token)
    token = JWT.decode(token, ENV['JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
    # return token[0...100] if ENV['RAILS_ENV'] == 'test'

    token
  end

  def generate_token(user_id, wordlist_id = nil)
    secret_key = ENV['JWT_SECRET_KEY']
    payload = if ENV['RAILS_ENV'] == 'test'
                { user_id: user_id, wordlist_id: wordlist_id }
              else
                { exp: (time_now + 1800).to_i, user_id: user_id, wordlist_id: wordlist_id }
              end

    JWT.encode(payload, secret_key, 'HS256')
  end
end
