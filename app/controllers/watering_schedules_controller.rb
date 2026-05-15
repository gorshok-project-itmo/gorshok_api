# app/controllers/watering_schedules_controller.rb
class WateringSchedulesController < ApplicationController
  before_action :set_plant, only: [:index, :create]
  before_action :set_watering_schedule, only: [:show, :update, :destroy, :toggle_active]

  # GET /plants/:plant_id/watering_schedules
  def index
    @watering_schedules = @plant.watering_schedules.order(:hour, :minute)
    render json: @watering_schedules
  end

  # GET /watering_schedules/1
  def show
    render json: @watering_schedule
  end

  # POST /plants/:plant_id/watering_schedules
  def create
    @watering_schedule = @plant.watering_schedules.new(watering_schedule_params)

    if @watering_schedule.save
      # Отправляем обновлённые расписания на ESP32
      send_schedules_to_esp32
      
      render json: @watering_schedule, status: :created
    else
      render json: { errors: @watering_schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /watering_schedules/1
  def update
    if @watering_schedule.update(watering_schedule_params)
      send_schedules_to_esp32
      
      render json: @watering_schedule
    else
      render json: { errors: @watering_schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /watering_schedules/1
  def destroy
    plant = @watering_schedule.plant
    @watering_schedule.destroy
    
    send_schedules_to_esp32(plant)
    
    head :no_content
  end

  # PATCH /watering_schedules/1/toggle_active
  def toggle_active
    @watering_schedule.update(active: !@watering_schedule.active)
    send_schedules_to_esp32
    
    render json: { 
      id: @watering_schedule.id, 
      active: @watering_schedule.active,
      message: "Schedule #{@watering_schedule.active ? 'activated' : 'deactivated'}"
    }
  end

  # GET /plants/:plant_id/watering_schedules/upcoming
  def upcoming
    today = Date.today.strftime('%A').downcase
    current_hour = Time.current.hour
    current_minute = Time.current.min
    
    @upcoming_schedules = @plant.watering_schedules
      .where(active: true)
      .select { |s| s.days_array.include?(today) }
      .sort_by { |s| [s.hour, s.minute] }
      .first(5)

    render json: @upcoming_schedules
  end

  private

  def set_plant
    @plant = Plant.find(params[:plant_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Plant not found" }, status: :not_found
  end

  def set_watering_schedule
    @watering_schedule = WateringSchedule.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Watering schedule not found" }, status: :not_found
  end

  def watering_schedule_params
    params.require(:watering_schedule).permit(:hour, :minute, :active, days: [])
  end

  def send_schedules_to_esp32(plant = nil)
    plant ||= @watering_schedule.plant
    device = plant.device
    
    if device.online?
      sender = Esp32::CommandSender.new(device)
      sender.add_schedules(plant)
    end
  end
end