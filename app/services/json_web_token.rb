class JsonWebToken
  ALGORITHM = "HS256".freeze
  SECRET_KEY = Rails.application.credentials.dig(:jwt, :secret_key)

  def self.encode(payload, exp = 24.hours.from_now)
    raise "JWT secret no configurado" if SECRET_KEY.blank?

    payload = payload.dup
    payload[:exp] = exp.to_i
    payload[:iat] = Time.now.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET_KEY, true, algorithm: ALGORITHM)[0]
    HashWithIndifferentAccess.new(body)
  rescue JWT::ExpiredSignature, JWT::DecodeError, JWT::VerificationError
    nil
  end
end
