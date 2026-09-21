class Product < ApplicationRecord
  belongs_to :business
  has_one_attached :image
  has_many :order_items, dependent: :restrict_with_error

  validate :image_format_and_size
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :visible, -> { where(available: true) }

  def in_stock?
    stock > 0
  end

  private

  def image_format_and_size
    return unless image.attached?

    unless image.blob.content_type.in?(%w[image/jpeg image/png image/webp])
      errors.add(:image, "debe ser JPG, PNG o WEBP")
    end

    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "no puede pesar más de 5MB")
    end
  end
end
