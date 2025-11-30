class Device < ApplicationRecord
  belongs_to :user
  has_many :watering_schedules, dependent: :destroy
  validates :name, presence: true
  validates :mode, presence: true
  validates :interval_hours, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :humidity_threshold, numericality: true, allow_nil: true
  validates :water_level, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
end