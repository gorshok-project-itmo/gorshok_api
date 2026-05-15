module Esp32
  class PollingService
    def self.start
      Thread.new do
        loop do
          sleep 300 # каждые 5 минут
          
          begin
            Device.where(status: :online).each do |device|
              # Проверяем, что устройство действительно подключено
              if Esp32::ConnectionManager.instance.connected?(device.device_identifier)
                sender = CommandSender.new(device)
                
                # Запрашиваем влажность воздуха
                sender.request_humidity
                sleep 1
                
                # Запрашиваем влажность почвы для каждого растения
                device.plants.each do |plant|
                  sender.request_humidity_plant(plant.plant_number)
                  sleep 1
                end
              else
                # Если устройство не подключено, но в БД online — исправляем
                device.mark_offline!
              end
            end
          rescue => e
            Rails.logger.error "[ESP32] Polling error: #{e.message}"
          end
        end
      end
    end
  end
end
