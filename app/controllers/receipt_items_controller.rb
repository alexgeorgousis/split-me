class ReceiptItemsController < ApplicationController
  before_action :set_split
  before_action :set_receipt_item

  def show
  end

  def update
    if @receipt_item.update(receipt_item_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("summary", partial: "splits/summary", locals: { split: @split }),
            turbo_stream.replace("receipt_item_#{@receipt_item.id}", partial: "receipt_items/receipt_item", locals: { receipt_item: @receipt_item })
          ]
        end
        format.html { redirect_to split_path(@split) }
      end
    else
      redirect_to split_path(@split), alert: "Failed to update receipt item."
    end
  end

  def destroy
    @receipt_item.destroy!
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("receipt_item_#{@receipt_item.id}"),
          turbo_stream.replace("summary", partial: "splits/summary", locals: { split: @split })
        ]
      end
      format.html { redirect_to split_path(@split) }
    end
  rescue => e
    flash[:alert] = "Failed to delete receipt item: #{e.message}"
    redirect_to split_path(@split)
  end

  def toggle_favourite
    favourite = Favourite.owned_by_user.find_by name: @receipt_item.name
    if favourite
      favourite.destroy
    else
      Favourite.owned_by_user.create! name: @receipt_item.name
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("receipt_item_#{@receipt_item.id}", partial: "receipt_items/receipt_item", locals: { receipt_item: @receipt_item })
      end
      format.html { redirect_back(fallback_location: split_path(@split)) }
    end
  end

  private

  def set_split
    @split = Split.owned_by_user.find params[:split_id]
  end

  def set_receipt_item
    @receipt_item = @split.receipt.receipt_items.find(params[:id])
  end

  def receipt_item_params
    params.permit(:split_mode)
  end
end
