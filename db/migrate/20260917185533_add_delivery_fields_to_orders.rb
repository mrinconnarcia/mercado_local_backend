class AddDeliveryFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :delivery_address, :string
    add_column :orders, :delivery_latitude, :decimal, precision: 10, scale: 6
    add_column :orders, :delivery_longitude, :decimal, precision: 10, scale: 6
    add_column :orders, :delivery_fee, :decimal, precision: 10, scale: 2
  end
end
