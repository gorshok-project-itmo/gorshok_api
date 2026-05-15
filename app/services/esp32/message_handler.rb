module Esp32
  class MessageHandler
    def initialize(ws)
      @ws = ws
      @device_identifier = nil
    end

    def handle(message)
      json = JSON.parse(message) rescue nil
      
      unless json
        if message =~ /"command":"humidity"/
          data_match = message.match(/"data":"(\{.+\})"/)
          data = data_match ? data_match[1] : ""
          device_match = message.match(/"device_id":"([^"]+)"/)
          @device_identifier = device_match ? device_match[1] : ""
          
          handle_humidity(data)
          return
        end
        Rails.logger.error "[ESP32] Failed to parse message: #{message}"
        return
      end

      command = json['command']
      data = json['data'] || ""
      @device_identifier = json['device_id']

      Rails.logger.info "[ESP32] Received: command=#{command}, data=#{data}, device=#{@device_identifier}"

      case command
      when 'register'
        handle_register
      when 'pong'
        handle_pong
      when 'device_info'
        handle_device_info(data)
      when 'humidity'
        handle_humidity(data)
      when 'humidityPlant'
        handle_humidity_plant(data)
      when 'addPlant'
        handle_add_plant_response(data)
      when 'addSchedules'
        handle_add_schedules_response(data)
      when 'setPlantMode'
        handle_set_plant_mode_response(data)
      when 'setMinEarthHumidity'
        handle_set_min_earth_humidity_response(data)
      when 'setMaxWateringTime'
        handle_set_max_watering_time_response(data)
      when 'welcome_ack'
        Rails.logger.info "[ESP32] Device #{@device_identifier} acknowledged welcome"
      else
        Rails.logger.warn "[ESP32] Unknown command: #{command}"
      end
    rescue => e
      Rails.logger.error "[ESP32] Error handling message: #{e.message}"
    end

    private

    def handle_register
      ConnectionManager.instance.register(@device_identifier, @ws)
      send_message({ command: 'welcome', data: 'Connected to server!' })
    end

    def handle_pong
      device = find_device
      device&.mark_online!
    end

    def handle_device_info(data)
      device = find_device
      return unless device
      
      begin
        info = JSON.parse(data)
        device.update(ip_address: extract_ip(info))
      rescue JSON::ParserError
        # ignore
      end
    end

    def handle_humidity(data)
      device = find_device
      return unless device

      humidity_val = nil
      temperature_val = nil

      # Пробуем разные форматы
      clean_data = data.gsub('\\"', '"')
      
      begin
        # Формат JSON: {"humidity":"45.0","temperature":"23.5"}
        sensor_data = JSON.parse(clean_data)
        humidity_val = sensor_data['humidity']&.to_f
        temperature_val = sensor_data['temperature']&.to_f
      rescue JSON::ParserError
        # Формат key=value: humidity=45.0,temperature=23.5
        pairs = clean_data.split(',')
        pairs.each do |pair|
          key, value = pair.split('=')
          if key && value
            case key.strip
            when 'humidity'
              humidity_val = value.strip.to_f
            when 'temperature'
              temperature_val = value.strip.to_f
            end
          end
        end
      end

      if humidity_val || temperature_val
        device.plants.each do |plant|
          plant.update(
            humidity_env: humidity_val,
            temperature_env: temperature_val
          )
        end
        Rails.logger.info "[ESP32] Environmental data saved: humidity=#{humidity_val}, temperature=#{temperature_val}"
      else
        Rails.logger.warn "[ESP32] No valid data in humidity message: #{data}"
      end
    end

    def handle_humidity_plant(data)
      device = find_device
      return unless device

      soil_value = nil
      plant_number = 1

      # Формат: "1:25" или "25"
      if data.to_s.include?(':')
        parts = data.to_s.split(':')
        plant_number = parts[0].to_i
        soil_value = parts[1].to_i
      else
        soil_value = data.to_i
      end

      if soil_value && plant_number.between?(1, 3)
        plant = device.plants.find_by(plant_number: plant_number)
        if plant
          plant.update(humidity_soil: soil_value)
          Rails.logger.info "[ESP32] Plant #{plant_number} soil humidity: #{soil_value}%"
        end
      end
    end

    def handle_add_plant_response(data)
      Rails.logger.info "[ESP32] Add plant response: #{data}"
    end

    def handle_add_schedules_response(data)
      Rails.logger.info "[ESP32] Add schedules response: #{data}"
    end

    def handle_set_plant_mode_response(data)
      Rails.logger.info "[ESP32] Set plant mode response: #{data}"
    end

    def handle_set_min_earth_humidity_response(data)
      Rails.logger.info "[ESP32] Set min earth humidity response: #{data}"
    end

    def handle_set_max_watering_time_response(data)
      Rails.logger.info "[ESP32] Set max watering time response: #{data}"
    end

    def send_message(hash)
      @ws.send(hash.to_json)
    rescue => e
      Rails.logger.error "[ESP32] Failed to send message: #{e.message}"
    end

    def find_device
      Device.find_by(device_identifier: @device_identifier)
    end

    def extract_ip(info)
      nil
    end
  end
end