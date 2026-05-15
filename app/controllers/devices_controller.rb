class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: [:show, :update, :destroy, :watering_status, :trigger_watering]

  # GET /devices
  def index
    @devices = current_user.devices.order(created_at: :desc)
    render json: @devices, include: { plants: { only: [:id, :plant_number, :name, :mode, :humidity_soil, :humidity_env, :temperature_env] } }
  end

  # GET /devices/1
  def show
    render json: @device, include: { plants: { include: :watering_schedules } }
  end

  # POST /devices
  def create
    @device = current_user.devices.new(device_params)
    @device.device_identifier = SecureRandom.hex(6) # временный ID, заменится при регистрации ESP32

    if @device.save
      render json: @device, status: :created
    else
      render json: { errors: @device.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /devices/1
  def update
    if @device.update(device_params)
      render json: @device
    else
      render json: { errors: @device.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /devices/1
  def destroy
    @device.destroy
    head :no_content
  end

  # GET /devices/1/watering_status
  def watering_status
    plants_status = @device.plants.map do |plant|
      {
        plant_number: plant.plant_number,
        name: plant.name,
        mode: plant.mode,
        humidity_soil: plant.humidity_soil,
        humidity_env: plant.humidity_env,
        temperature_env: plant.temperature_env,
        needs_watering: plant.needs_watering?,
        min_earth_humidity: plant.min_earth_humidity,
        max_watering_time: plant.max_watering_time
      }
    end

    status = {
      device_name: @device.name,
      device_identifier: @device.device_identifier,
      status: @device.status,
      last_seen_at: @device.last_seen_at,
      plants: plants_status
    }

    render json: status
  end

  # POST /devices/1/trigger_watering
  def trigger_watering
    plant_number = params[:plant_number] || 1
    plant = @device.plants.find_by(plant_number: plant_number)
    
    unless plant
      return render json: { error: "Plant ##{plant_number} not found on this device" }, status: :not_found
    end

    # Отправляем команду на ESP32
    sender = Esp32::CommandSender.new(@device)
    
    if @device.online?
      success = sender.water_plant(plant_number)
      
      if success
        render json: {
          message: "Watering triggered for plant ##{plant_number}",
          plant_number: plant_number,
          duration_minutes: plant.max_watering_time / 60,
          started_at: Time.current
        }
      else
        render json: { error: "Failed to send watering command to device" }, status: :service_unavailable
      end
    else
      render json: { error: "Device is offline" }, status: :service_unavailable
    end
  end

  # GET /devices/summary
  def summary
    user_devices = current_user.devices
    
    summary = {
      total_devices: user_devices.count,
      online_devices: user_devices.where(status: :online).count,
      total_plants: Plant.where(device_id: user_devices.pluck(:id)).count,
      plants_needing_water: Plant.where(device_id: user_devices.pluck(:id))
                                 .select { |p| p.needs_watering? }.count
    }

    render json: summary
  end

  private

  def set_device
    @device = current_user.devices.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Device not found" }, status: :not_found
  end

  def device_params
    params.require(:device).permit(:name, :ip_address)
  end
end