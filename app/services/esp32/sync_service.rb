module Esp32
  class SyncService
    def initialize(device)
      @device = device
      @sender = CommandSender.new(device)
    end

    def sync_all
      Rails.logger.info "[ESP32] Starting sync for device #{@device.device_identifier}"
      
      @device.plants.each do |plant|
        sync_plant(plant)
      end
      
      Rails.logger.info "[ESP32] Sync completed for device #{@device.device_identifier}"
    end

    def sync_plant(plant)
      # Отправляем конфигурацию растения
      @sender.add_plant(plant)
      sleep 0.2
      
      @sender.set_plant_mode(plant)
      sleep 0.2
      
      @sender.set_min_earth_humidity(plant)
      sleep 0.2
      
      @sender.set_max_watering_time(plant)
      sleep 0.2
      
      # Отправляем расписания, если есть
      if plant.watering_schedules.any?
        @sender.add_schedules(plant)
        sleep 0.2
      end
    end
  end
end