class WateringSchedule < ApplicationRecord
  belongs_to :device

  validates :day_of_week, presence: true, inclusion: { 
    in: %w[monday tuesday wednesday thursday friday saturday sunday] 
  }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    
    begin
      normalized_start = start_time.to_time
      normalized_end = end_time.to_time
      
      if normalized_end <= normalized_start
        errors.add(:end_time, "must be after start time")
      end
    rescue ArgumentError, NoMethodError => e
      errors.add(:base, "Invalid time format: #{e.message}")
    end
  end
end