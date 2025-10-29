class SplitsController < ApplicationController
  before_action :set_split, only: %i[ show destroy process_receipt ]

  def index
    @splits = Split.owned_by_user.order created_at: :desc
  end

  def show
  end

  def create
    @split = Split.owned_by_user.build split_params

    if @split.save
      process_receipt if @split.receipt&.attached?
      redirect_to splits_path
    else
      redirect_to splits_path, alert: @split.errors.full_messages.to_sentence
    end
  end

  def destroy
    @split.destroy!
    redirect_to splits_path
  end

  def process_receipt
    @split.receipt.process_later
  end

  private
    def set_split
      @split = Split.owned_by_user.find params[:id]
    end

    def split_params
      params.fetch(:split, {}).permit(receipt_attributes: [ :file ])
    end
end
