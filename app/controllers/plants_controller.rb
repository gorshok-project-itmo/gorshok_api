class PlantsController < ApplicationController
    before_action :set_plant, only: [:show, :update, :destroy]

  # GET /plants
  def index
    @plants = Plant.order(created_at: :desc)
    render json: @plants
  end

  # GET /plants/:id
  def show
    render json: @plant
  end

  # POST /plants
  def create
    @plant = Plant.new(plant_params)

    if @plant.save
      render json: @plant, status: :created
    else
      render json: { errors: @plant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /plants/:id
  def update
    if @plant.update(plant_params)
      render json: @plant
    else
      render json: { errors: @plant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /plants/:id
  def destroy
    @plant.destroy
    head :no_content
  end

  # GET /plants/latest
  def latest
    @plant = Plant.order(created_at: :desc).first
    if @plant
      render json: @plant
    else
      render json: { error: "No plants found" }, status: :not_found
    end
  end

  # GET /plants/stats
  def stats
    plants = Plant.where(created_at: 24.hours.ago..Time.current)
    
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

  def set_plant
    @plant = Plant.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Plant not found" }, status: :not_found
  end

  def plant_params
    params.require(:plant).permit(:humidity_soil, :humidity_env, :temperature_env)
  end
end
