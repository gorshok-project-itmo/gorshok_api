class ChangeTimeFormat < ActiveRecord::Migration[7.1]
  def change
    change_column :watering_schedules, :start_time, :string
    change_column :watering_schedules, :end_time, :string
  end
end
