class WateringSchedule < ApplicationRecord
  belongs_to :plant
  
  validates :hour, presence: true, 
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
  validates :minute, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 59 }
  validates :days, presence: true
  
  DAYS = %w[monday tuesday wednesday thursday friday saturday sunday].freeze
  
  validate :days_must_be_valid
  
  def days_array
    days.is_a?(Array) ? days : JSON.parse(days)
  rescue
    []
  end
  
  private
  
  def days_must_be_valid
    days_array.each do |day|
      unless DAYS.include?(day)
        errors.add(:days, "contains invalid day: #{day}")
      end
    end
  end
end