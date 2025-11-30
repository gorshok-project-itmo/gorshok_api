class CreateWateringSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :watering_schedules do |t|
      t.belongs_to :device
      t.string :day_of_week             # "wednesday"
      t.time :start_time                # 09:00
      t.time :end_time                  # 09:20
      t.boolean :active, default: true   
      t.timestamps
    end
  end
end
