class Plant < ApplicationRecord
  belongs_to :device
  has_many :watering_schedules, dependent: :destroy
  
  validates :plant_number, presence: true, 
            inclusion: { in: 1..3 },
            uniqueness: { scope: :device_id }
  
  enum :mode, { manual: 0, schedule: 1, humidity: 2, mixed: 3 }
  
  def needs_watering?
    return false if humidity_soil.nil?
    humidity_soil < min_earth_humidity
  end
end