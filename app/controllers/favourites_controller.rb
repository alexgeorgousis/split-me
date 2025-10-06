class FavouritesController < ApplicationController
  before_action :set_favourite, only: %i[ show edit update destroy ]

  # GET /favourites or /favourites.json
  def index
    @favourites = Favourite.all
  end

  # GET /favourites/1 or /favourites/1.json
  def show
  end

  # GET /favourites/new
  def new
    @favourite = Favourite.new
  end

  # GET /favourites/1/edit
  def edit
  end

  # POST /favourites or /favourites.json
  def create
    @favourite = Favourite.new(favourite_params)

    respond_to do |format|
      if @favourite.save
        format.html { redirect_to @favourite, notice: "Favourite was successfully created." }
        format.json { render :show, status: :created, location: @favourite }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @favourite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /favourites/1 or /favourites/1.json
  def update
    respond_to do |format|
      if @favourite.update(favourite_params)
        format.html { redirect_to @favourite, notice: "Favourite was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @favourite }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @favourite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /favourites/1 or /favourites/1.json
  def destroy
    @favourite.destroy!

    respond_to do |format|
      format.html { redirect_to favourites_path, notice: "Favourite was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favourite
      @favourite = Favourite.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def favourite_params
      params.expect(favourite: [ :name, :string ])
    end
end
