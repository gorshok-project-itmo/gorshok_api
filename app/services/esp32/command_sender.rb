module Esp32
  class CommandSender
    def initialize(device)
      @device = device
      @device_identifier = device.device_identifier
    end

    def send_command(command, data = "")
      ws = ConnectionManager.instance.get_connection(@device_identifier)
      
      unless ws
        Rails.logger.warn "[ESP32] Device #{@device_identifier} is not connected"
        return false
      end

      message = {
        command: command,
        data: data.to_s
      }.to_json

      ws.send(message)
      Rails.logger.info "[ESP32] Sent to #{@device_identifier}: #{command} #{data}"
      true
    rescue => e
      Rails.logger.error "[ESP32] Failed to send command to #{@device_identifier}: #{e.message}"
      false
    end

    # Удобные методы для конкретных команд

    def add_plant(plant)
      send_command('addPlant', " #{plant.plant_number}")
    end

    def add_schedules(plant)
      schedules_data = plant.watering_schedules.map do |schedule|
        {
          hour: schedule.hour.to_s.rjust(2, '0').to_i,
          minute: schedule.minute.to_s.rjust(2, '0').to_i,
          days: schedule.days_array
        }
      end

      json_data = {
        plantNumber: plant.plant_number,
        schedules: schedules_data
      }.to_json

      send_command('addSchedules', " #{json_data}")
    end

    def set_plant_mode(plant)
      json_data = {
        plantNumber: plant.plant_number,
        mode: Plant.modes[plant.mode]
      }.to_json

      send_command('setPlantMode', " #{json_data}")
    end

    def set_min_earth_humidity(plant)
      json_data = {
        plantNumber: plant.plant_number,
        MinEarthHumidity: plant.min_earth_humidity
      }.to_json

      send_command('setMinEarthHumidity', " #{json_data}")
    end

    def set_max_watering_time(plant)
      json_data = {
        plantNumber: plant.plant_number,
        MaxWateringTime: plant.max_watering_time
      }.to_json

      send_command('setMaxWateringTime', " #{json_data}")
    end

    def water_plant(plant_number)
      send_command('water', " #{plant_number}")
    end

    def stop_watering
      send_command('water', "")
    end

    def request_humidity
      send_command('humidity', "")
    end

    def request_humidity_plant(plant_number)
      send_command('humidityPlant', " #{plant_number}")
    end

    def ping
      send_command('ping', 'Are you alive?')
    end
  end
end