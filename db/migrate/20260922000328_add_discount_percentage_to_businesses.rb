class AddDiscountPercentageToBusinesses < ActiveRecord::Migration[8.1]
  def change
    add_column :businesses, :discount_percentage, :decimal, precision: 5, scale: 2, default: 0.0, null: false
  end
end
