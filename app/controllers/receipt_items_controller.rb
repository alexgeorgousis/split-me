class ReceiptItemsController < ApplicationController
  before_action :set_order
  before_action :set_receipt_item

  def toggle_selection
    @receipt_item.update!(selected: !@receipt_item.selected)
    redirect_to bill_breakdown_order_path(@order)
  end

  def update_split_mode
    @receipt_item.update!(split_mode: params[:split_mode])
    redirect_to bill_breakdown_order_path(@order)
  end

  def destroy
    @receipt_item.destroy!
    redirect_to bill_breakdown_order_path(@order), notice: "Receipt item removed successfully."
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_receipt_item
    @receipt_item = @order.receipt_items.find(params[:id])
  end
end
