class Business < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :business_hours, dependent: :destroy
  has_many :reviews, dependent: :destroy

  enum :status, pending: 0, approved: 1, suspended: 2

  validates :name, presence: true
  validates :address, presence: true

  scope :visible, -> { where(active: true, status: :approved) }

  before_validation :set_owner_as_business_owner, on: :create

  def open_now?
    hour = business_hours.find_by(day_of_week: Time.zone.now.wday)
    return false if hour.nil? || hour.closed?

    now = Time.zone.now.strftime("%H:%M:%S")
    now.between?(hour.opens_at.strftime("%H:%M:%S"), hour.closes_at.strftime("%H:%M:%S"))
  end

  # parte del geocoding "fórmula de Haversine"
  EARTH_RADIUS_KM = 6371

  def distance_to(lat, lng)
    return nil if latitude.blank? || longitude.blank? || lat.blank? || lng.blank?

    rad_lat1 = latitude.to_f * Math::PI / 180
    rad_lat2 = lat.to_f * Math::PI / 180
    delta_lat = (lat.to_f - latitude.to_f) * Math::PI / 180
    delta_lng = (lng.to_f - longitude.to_f) * Math::PI / 180

    a = Math.sin(delta_lat / 2)**2 +
        Math.cos(rad_lat1) * Math.cos(rad_lat2) * Math.sin(delta_lng / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    (EARTH_RADIUS_KM * c).round(2)
  end

  def delivers_to?(lat, lng)
    distance = distance_to(lat, lng)
    return false if distance.nil?

    distance <= (delivery_radius_km || 0)
  end

  def delivery_fee_for(lat, lng, subtotal)
    distance = distance_to(lat, lng)
    return nil if distance.nil?

    return 0 if free_delivery_over.present? && subtotal >= free_delivery_over

    base = delivery_base_fee || 0
    per_km = delivery_fee_per_km || 0

    (base + (distance * per_km)).round(2)
  end

  def average_rating
    reviews.average(:rating)&.round(1)
  end

  def reviews_count
    reviews.count
  end

  private

  def set_owner_as_business_owner
    user&.business_owner! unless user&.business_owner? || user&.admin?
  end
end
