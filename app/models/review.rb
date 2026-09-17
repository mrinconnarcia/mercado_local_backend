class Review < ApplicationRecord
  belongs_to :order
  belongs_to :user
  belongs_to :business
end
