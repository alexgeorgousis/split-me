class SplitsController < ApplicationController
  before_action :set_split, only: %i[ show edit update destroy process_receipt ]

  def index
    @splits = Split.owned_by_user
  end

  def show
  end

  def new
    @split = Split.new
  end

  def edit
  end

  def create
    @split = Split.owned_by_user.build split_params

    if @split.save
      redirect_to splits_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @split.update(split_params)
      redirect_to splits_path, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @split.destroy!
    redirect_to splits_path
  end

  def process_receipt
    if @split.process_receipt
      redirect_to split_path(@split)
    else
      redirect_to splits_path, alert: "We couldn't process your receipt :("
    end
  end

  private
    def set_split
      @split = Split.owned_by_user.find params[:id]
    end

    def split_params
      params.require(:split).permit(receipt_attributes: [ :file ])
    end
end
