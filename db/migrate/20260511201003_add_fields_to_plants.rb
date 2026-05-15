class AddFieldsToPlants < ActiveRecord::Migration[7.1]
  def change
    change_table :plants do |t|
      t.references :device, null: false, foreign_key: true
      t.integer :plant_number, null: false  # 1, 2 или 3
      t.integer :mode, default: 0  # 0=manual, 1=schedule, 2=humidity, 3=mixed
      t.integer :min_earth_humidity, default: 30
      t.integer :max_watering_time, default: 60  # в секундах
      t.string :name
      t.text :description
    end
    
    add_index :plants, [:device_id, :plant_number], unique: true
  end
end
