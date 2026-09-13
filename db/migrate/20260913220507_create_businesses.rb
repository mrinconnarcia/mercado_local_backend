class CreateBusinesses < ActiveRecord::Migration[7.1]
  def change
    create_table :businesses do |t|
      t.string :name, null: false
      t.text :description
      t.string :address
      t.string :phone
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end