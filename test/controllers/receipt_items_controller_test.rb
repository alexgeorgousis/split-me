require "test_helper"

class ReceiptItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @split = splits(:one)
    @receipt_item = @split.receipt.receipt_items.first
    sign_in_as users(:one)
  end

  test "should update split_mode" do
    patch split_receipt_item_url(@split, @receipt_item), params: { split_mode: "mine" }
    assert_redirected_to split_path(@split)
    assert_equal "mine", @receipt_item.reload.split_mode
  end

  test "should destroy receipt_item" do
    assert_difference("ReceiptItem.count", -1) do
      delete split_receipt_item_url(@split, @receipt_item)
    end
    assert_redirected_to split_path(@split)
  end
end
