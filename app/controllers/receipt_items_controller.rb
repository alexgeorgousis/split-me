class ReceiptItemsController < ApplicationController
  before_action :set_order
  before_action :set_receipt_item

  def toggle_selection
    @receipt_item.update!(selected: !@receipt_item.selected)

    respond_to do |format|
      format.html { redirect_to bill_breakdown_order_path(@order) }
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(
          "receipt_item_#{@receipt_item.id}",
          partial: "receipt_items/receipt_item",
          locals: { receipt_item: @receipt_item, order: @order }
        )
      }
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_receipt_item
    @receipt_item = @order.receipt_items.find(params[:id])
  end
end
