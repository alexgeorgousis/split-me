class MealsController < ApplicationController
  before_action :set_meal, only: %i[ show edit update destroy ]

  def index
    @meals = Meal.all
  end

  def show
  end

  def new
    @meal = Meal.new
    @meal.meal_ingredients.build
  end

  def edit
    @meal.meal_ingredients.build if @meal.meal_ingredients.empty?
  end

  def create
    @meal = Meal.new(meal_params)

    if @meal.save
      redirect_to @meal, notice: "Meal was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @meal.update(meal_params)
      redirect_to @meal, notice: "Meal was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meal.destroy!
    redirect_to meals_path, notice: "Meal was successfully destroyed.", status: :see_other
  end

  private
    def set_meal
      @meal = Meal.find(params.expect(:id))
    end

    def meal_params
      params.require(:meal).permit(:name, meal_ingredients_attributes: [ :id, :ingredient_id, :_destroy ])
    end
end
