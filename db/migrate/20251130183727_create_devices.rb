class CreateDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :devices do |t|
      t.string :name                    # "MyDevice1"
      t.string :mode                    # "Автоматический", "По расписанию"
      t.integer :interval_hours         # 3 (часы)
      t.integer :duration_minutes       # 20 (минуты)
      t.float :humidity_threshold       # 30%
      t.datetime :next_watering         # 15:00–15:20
      t.float :water_level              # 80%
      t.references :user, null: false, foreign_key: true  # владелец устройства
      t.timestamps
    end
  end
end
