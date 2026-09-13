class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.boolean :available, null: false, default: true
      t.integer :stock, null: false, default: 0
      t.references :business, null: false, foreign_key: true

      t.timestamps
    end
  end
end
