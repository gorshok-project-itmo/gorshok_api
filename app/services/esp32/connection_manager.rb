module Esp32
  class ConnectionManager
    include Singleton

    def initialize
      @connections = {} # device_identifier -> websocket
      @mutex = Mutex.new
      start_heartbeat
    end

    def register(device_identifier, ws)
      @mutex.synchronize do
        @connections[device_identifier] = ws
        Rails.logger.info "[ESP32] Device registered: #{device_identifier}"
      end
      
      # Найти или создать устройство в БД
      device = Device.find_by(device_identifier: device_identifier)
      
      if device
        # Устройство найдено — обновляем статус
        device.mark_online!
        Rails.logger.info "[ESP32] Found existing device: #{device.id}"
      else
        # Создаём новое устройство
        device = Device.create!(
          device_identifier: device_identifier,
          name: "ESP32 Device",
          user: User.first,
          status: :online,
          last_seen_at: Time.current
        )
        Rails.logger.info "[ESP32] Created new device: #{device.id}"
      end
      
      # Синхронизировать состояние
      SyncService.new(device).sync_all
    end

    def unregister(device_identifier)
      @mutex.synchronize do
        @connections.delete(device_identifier)
        Rails.logger.info "[ESP32] Device disconnected: #{device_identifier}"
      end
      
      device = Device.find_by(device_identifier: device_identifier)
      device&.mark_offline!
    end

    def get_connection(device_identifier)
      @mutex.synchronize do
        @connections[device_identifier]
      end
    end

    def connected?(device_identifier)
      @mutex.synchronize do
        @connections.key?(device_identifier)
      end
    end

    def device_identifiers
      @mutex.synchronize do
        @connections.keys
      end
    end

    private

    def start_heartbeat
      Thread.new do
        loop do
          sleep 30
          @mutex.synchronize do
            @connections.each do |device_id, ws|
              begin
                ws.send({ command: 'ping', data: 'Are you alive?' }.to_json)
              rescue => e
                Rails.logger.error "[ESP32] Heartbeat failed for #{device_id}: #{e.message}"
                @connections.delete(device_id)
              end
            end
          end
        end
      end
    end
  end
end