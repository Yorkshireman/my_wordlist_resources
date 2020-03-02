# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['CORS_URLS'],
            /https:\/\/mywordlist-[a-z0-9-]+.herokuapp.com/ # for Heroku review apps (second half of those urls are randomly generated)

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options]
  end
end
