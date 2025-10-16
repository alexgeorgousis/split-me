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
      redirect_to splits_path, notice: "Split was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @split.update(split_params)
      redirect_to splits_path, notice: "Split was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @split.destroy!
    redirect_to splits_path, notice: "Split was successfully destroyed.", status: :see_other
  end

  def process_receipt
    unless @split.receipt&.file&.attached?
      redirect_to splits_path, alert: "No receipt file attached."
      return
    end

    @split.process_receipt!
    redirect_to split_path(@split), notice: "Receipt processed successfully!"
  rescue => e
    redirect_to splits_path, alert: "Failed to process receipt: #{e.message}"
  end

  private
    def set_split
      @split = Split.owned_by_user.find params[:id]
    end

    def split_params
      params.require(:split).permit(receipt_attributes: [ :file ])
    end
end
