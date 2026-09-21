class Rack::Attack
  # Máximo 5 intentos de login por IP cada 20 segundos
  throttle("login/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end

  # Máximo 5 intentos de login por email, independiente de la IP
  # (evita que alguien rote de IP para seguir probando la misma cuenta)
  throttle("login/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/api/v1/auth/login" && req.post?
      req.params.dig("email")&.downcase&.strip
    end
  end

  # Límite general para el resto de la API: 300 requests/5min por IP
  throttle("api/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api/")
  end

  throttle('businesses/create', limit: 10, period: 1.hour) do |req|
    if req.path == '/api/v1/businesses' && req.post?
      req.env['HTTP_AUTHORIZATION']
    end
  end

  self.throttled_responder = lambda do |req|
    [ 429, { "Content-Type" => "application/json" },
     [ { error: "Demasiados intentos. Esperá unos segundos e intentá de nuevo." }.to_json ] ]
  end
end
