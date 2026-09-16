class AddConfirmedAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :confirmed_at, :datetime
  end
end
