class FavouritesController < ApplicationController
  before_action :set_favourite, only: %i[ show edit update destroy ]

  def index
    @favourites = Favourite.owned_by_user
  end

  def show
  end

  def new
    @favourite = Favourite.new
  end

  def edit
  end

  def create
    @favourite = Favourite.owned_by_user.build favourite_params

    if @favourite.save
      redirect_to @favourite, notice: "Favourite was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @favourite.update(favourite_params)
      redirect_to @favourite, notice: "Favourite was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @favourite.destroy!

    respond_to do |format|
      format.html { redirect_to favourites_path, notice: "Favourite was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_favourite
      @favourite = Favourite.owned_by_user.find params[:id]
    end

    def favourite_params
      params.expect(favourite: [ :name ])
    end
end
