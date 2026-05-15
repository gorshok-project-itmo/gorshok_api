# config/initializers/esp32.rb
Rails.application.config.after_initialize do
  # Запускаем периодический опрос ESP32
  Esp32::PollingService.start
  
  Rails.logger.info "[ESP32] WebSocket server and polling service initialized"
end
