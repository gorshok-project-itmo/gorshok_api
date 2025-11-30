class DevicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_device, only: [:show, :update, :destroy, :watering_status, :trigger_watering]

  # GET /devices
  def index
    @devices = current_user.devices.order(created_at: :desc)
    render json: @devices
  end

  # GET /devices/1
  def show
    render json: @device
  end

  # POST /devices
  def create
    @device = current_user.devices.new(device_params)

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
    status = {
      device_name: @device.name,
      mode: @device.mode,
      next_watering: @device.next_watering,
      water_level: @device.water_level,
      humidity_threshold: @device.humidity_threshold,
      needs_watering: needs_watering?(@device)
    }

    render json: status
  end

  # POST /devices/1/trigger_watering
  def trigger_watering
    watering_response = {
      message: "Watering triggered for #{@device.name}",
      duration: @device.duration_minutes,
      started_at: Time.current,
      estimated_finish: Time.current + @device.duration_minutes.minutes,
      water_level_before: @device.water_level
    }

    # Обновляем уровень воды (уменьшаем на 5% за полив)
    new_water_level = [@device.water_level - 5.0, 0].max
    @device.update(water_level: new_water_level)

    watering_response[:water_level_after] = new_water_level

    render json: watering_response
  end

  # GET /devices/summary
  def summary
    user_devices = current_user.devices
    
    summary = {
      total_devices: user_devices.count,
      devices_by_mode: user_devices.group(:mode).count,
      average_water_level: user_devices.average(:water_level),
      low_water_devices: user_devices.where("water_level < ?", 20.0).count,
      next_watering_devices: user_devices.where("next_watering <= ?", 24.hours.from_now).count
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
    params.require(:device).permit(
      :name, 
      :mode, 
      :interval_hours, 
      :duration_minutes, 
      :humidity_threshold, 
      :next_watering, 
      :water_level
    )
  end

  def needs_watering?(device)
    device.water_level > 10.0
  end
end