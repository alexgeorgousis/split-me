class ReceiptItemsController < ApplicationController
  before_action :set_order
  before_action :set_receipt_item

  def update
    if @receipt_item.update(receipt_item_params)
      redirect_to order_path(@order)
    else
      redirect_to order_path(@order), alert: "Failed to update receipt item."
    end
  end

  def destroy
    @receipt_item.destroy!
    redirect_to order_path(@order)
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_receipt_item
    @receipt_item = @order.receipt.receipt_items.find(params[:id])
  end

  def receipt_item_params
    params.permit(:split_mode, :selected)
  end
end
