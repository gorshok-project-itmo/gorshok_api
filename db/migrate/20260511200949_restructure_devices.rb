class RestructureDevices < ActiveRecord::Migration[7.1]
  def change
    change_table :devices do |t|
      # Удаляем поля, которые переедут в Plant
      t.remove :mode
      t.remove :interval_hours
      t.remove :duration_minutes
      t.remove :humidity_threshold
      t.remove :next_watering
      t.remove :water_level
      
      # Добавляем поля для связи с ESP32
      t.string :device_identifier, null: false, default: ""
      t.datetime :last_seen_at
      t.integer :status, default: 0  # 0=offline, 1=online
      t.string :ip_address
    end
    
    add_index :devices, :device_identifier, unique: true
  end
end
