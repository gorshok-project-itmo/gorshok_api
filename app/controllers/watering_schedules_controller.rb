class WateringSchedulesController < ApplicationController
  before_action :set_watering_schedule, only: [:show, :update, :destroy, :toggle_active]

  # GET /devices/:device_id/watering_schedules
  def index
    @watering_schedules = WateringSchedule.where(device_id: params[:device_id])
    render json: @watering_schedules
  end

  # GET /watering_schedules/1
  def show
    render json: @watering_schedule
  end

  # POST /devices/:device_id/watering_schedules
  def create
    @watering_schedule = WateringSchedule.new(watering_schedule_params)
    @watering_schedule.device_id = params[:device_id]

    if @watering_schedule.save
      render json: @watering_schedule, status: :created
    else
      render json: { errors: @watering_schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /watering_schedules/1
  def update
    if @watering_schedule.update(watering_schedule_params)
      render json: @watering_schedule
    else
      render json: { errors: @watering_schedule.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /watering_schedules/1
  def destroy
    @watering_schedule.destroy
    head :no_content
  end

  # PATCH /watering_schedules/1/toggle_active
  def toggle_active
    @watering_schedule.update(active: !@watering_schedule.active)
    render json: { 
      id: @watering_schedule.id, 
      active: @watering_schedule.active,
      message: "Schedule #{@watering_schedule.active ? 'activated' : 'deactivated'}"
    }
  end

  # GET /devices/:device_id/watering_schedules/upcoming
  def upcoming
    today = Date.today.strftime('%A').downcase
    current_time = Time.current
    
    @upcoming_schedules = WateringSchedule
      .where(device_id: params[:device_id])
      .where(active: true)
      .where("day_of_week = ? OR (day_of_week = ? AND start_time > ?)", 
             today, today, current_time.strftime('%H:%M:%S'))
      .order(:day_of_week, :start_time)
      .limit(5)

    render json: @upcoming_schedules
  end

  private

  def set_watering_schedule
    @watering_schedule = WateringSchedule.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Watering schedule not found" }, status: :not_found
  end

  def watering_schedule_params
    params.require(:watering_schedule).permit(:day_of_week, :start_time, :end_time, :active)
  end
end