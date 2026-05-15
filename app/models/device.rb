# app/models/device.rb
class Device < ApplicationRecord
  belongs_to :user
  has_many :plants, dependent: :destroy
  
  validates :name, presence: true
  validates :device_identifier, presence: true, uniqueness: true
  
  enum :status, { offline: 0, online: 1 }
  
  def connected?
    online?
  end
  
  def mark_online!
    update(status: :online, last_seen_at: Time.current)
  end
  
  def mark_offline!
    update(status: :offline)
  end
end