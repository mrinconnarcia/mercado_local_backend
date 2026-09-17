class AddDeliveryFieldsToBusinesses < ActiveRecord::Migration[8.1]
  def change
    add_column :businesses, :latitude, :decimal, precision: 10, scale: 6
    add_column :businesses, :longitude, :decimal, precision: 10, scale: 6
    add_column :businesses, :delivery_radius_km, :decimal, precision: 5, scale: 2
    add_column :businesses, :delivery_base_fee, :decimal, precision: 10, scale: 2
    add_column :businesses, :delivery_fee_per_km, :decimal, precision: 10, scale: 2
    add_column :businesses, :free_delivery_over, :decimal, precision: 10, scale: 2
  end
end
