class CreateBusinessHours < ActiveRecord::Migration[8.1]
  def change
    create_table :business_hours do |t|
      t.references :business, null: false, foreign_key: true
      t.integer :day_of_week, null: false
      t.time :opens_at
      t.time :closes_at
      t.boolean :closed, null: false, default: false

      t.timestamps
    end
    add_index :business_hours, [ :business_id, :day_of_week ], unique: true
  end
end
