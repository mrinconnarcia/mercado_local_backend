Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:4200' # puerto default de Ember

    resource '*',
      headers: :any,
      expose: ['Authorization'],
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
