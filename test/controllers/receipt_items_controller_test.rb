require "test_helper"

class ReceiptItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
    @receipt_item = @order.receipt.receipt_items.first
  end

  test "should update split_mode" do
    patch order_receipt_item_url(@order, @receipt_item), params: { split_mode: "mine" }
    assert_redirected_to order_path(@order)
    assert_equal "mine", @receipt_item.reload.split_mode
  end

  test "should destroy receipt_item" do
    assert_difference("ReceiptItem.count", -1) do
      delete order_receipt_item_url(@order, @receipt_item)
    end
    assert_redirected_to order_path(@order)
  end
end
