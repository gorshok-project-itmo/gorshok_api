# app/controllers/plants_controller.rb
class PlantsController < ApplicationController
  before_action :set_device, only: [:index, :create]
  before_action :set_plant, only: [:show, :update, :destroy]

  # GET /devices/:device_id/plants
  def index
    @plants = @device.plants.order(:plant_number)
    render json: @plants, include: :watering_schedules
  end

  # GET /plants/:id
  def show
    render json: @plant, include: :watering_schedules
  end

  # POST /devices/:device_id/plants
  def create
    # Проверяем, что plant_number в диапазоне 1-3
    unless (1..3).include?(plant_params[:plant_number].to_i)
      return render json: { error: "Plant number must be 1, 2, or 3" }, status: :unprocessable_entity
    end

    @plant = @device.plants.new(plant_params)

    if @plant.save
      # Отправляем команду на ESP32
      if @device.online?
        sender = Esp32::CommandSender.new(@device)
        sender.add_plant(@plant)
        sleep 0.2
        sender.set_plant_mode(@plant)
        sleep 0.2
        sender.set_min_earth_humidity(@plant)
        sleep 0.2
        sender.set_max_watering_time(@plant)
      end

      render json: @plant, status: :created, include: :watering_schedules
    else
      render json: { errors: @plant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /plants/:id
  def update
    if @plant.update(plant_params)
      # Отправляем изменения на ESP32
      if @plant.device.online?
        sender = Esp32::CommandSender.new(@plant.device)
        
        if plant_params.key?(:mode)
          sender.set_plant_mode(@plant)
          sleep 0.2
        end
        
        if plant_params.key?(:min_earth_humidity)
          sender.set_min_earth_humidity(@plant)
          sleep 0.2
        end
        
        if plant_params.key?(:max_watering_time)
          sender.set_max_watering_time(@plant)
        end
      end

      render json: @plant, include: :watering_schedules
    else
      render json: { errors: @plant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /plants/:id
  def destroy
    device = @plant.device
    @plant.destroy
    
    # Уведомляем ESP32 (опционально, в протоколе нет команды удаления)
    # Можно просто синхронизировать заново
    if device.online?
      Esp32::SyncService.new(device).sync_all
    end
    
    head :no_content
  end

  # GET /plants/latest
  def latest
    @plant = Plant.order(updated_at: :desc).first
    if @plant
      render json: @plant
    else
      render json: { error: "No plants found" }, status: :not_found
    end
  end

  # GET /plants/stats
  def stats
    plants = Plant.where(updated_at: 24.hours.ago..Time.current)
    
    stats = {
      total_records: plants.count,
      avg_soil_humidity: plants.average(:humidity_soil),
      avg_env_humidity: plants.average(:humidity_env),
      avg_temperature: plants.average(:temperature_env),
      max_temperature: plants.maximum(:temperature_env),
      min_temperature: plants.minimum(:temperature_env)
    }

    render json: stats
  end

  private

  def set_device
    @device = Device.find(params[:device_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Device not found" }, status: :not_found
  end

  def set_plant
    @plant = Plant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Plant not found" }, status: :not_found
  end

  def plant_params
    params.require(:plant).permit(
      :plant_number,
      :name,
      :description,
      :mode,
      :min_earth_humidity,
      :max_watering_time,
      :humidity_soil,
      :humidity_env,
      :temperature_env
    )
  end
end