class BusinessHour < ApplicationRecord
  belongs_to :business

  DAYS = %w[Domingo Lunes Martes Miércoles Jueves Viernes Sábado].freeze

  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validate :times_present_unless_closed

  def day_name
    DAYS[day_of_week]
  end

  private

  def times_present_unless_closed
    return if closed?

    errors.add(:opens_at, "no puede estar vacío si el día no está cerrado") if opens_at.blank?
    errors.add(:closes_at, "no puede estar vacío si el día no está cerrado") if closes_at.blank?
  end
end
