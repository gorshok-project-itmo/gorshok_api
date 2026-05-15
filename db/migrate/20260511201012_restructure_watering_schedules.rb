class RestructureWateringSchedules < ActiveRecord::Migration[7.1]
  def change
    change_table :watering_schedules do |t|
      # Удаляем старые поля
      t.remove :device_id
      t.remove :day_of_week
      t.remove :start_time
      t.remove :end_time
      
      # Добавляем новые поля
      t.references :plant, null: false, foreign_key: true
      t.integer :hour, null: false, default: 6
      t.integer :minute, null: false, default: 0
      t.jsonb :days, default: []  # ["monday", "tuesday", ...]
    end
  end
end
