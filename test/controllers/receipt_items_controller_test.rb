require "test_helper"

class ReceiptItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @receipt_item = receipt_items(:mine)
    sign_in_as users(:one)
  end

  test "should update split_mode" do
    patch split_receipt_item_url(@receipt_item.split, @receipt_item), params: { split_mode: "mine" }
    assert_redirected_to split_path(@receipt_item.split)
    assert_equal "mine", @receipt_item.reload.split_mode
  end

  test "should destroy receipt_item" do
    assert_difference("ReceiptItem.count", -1) do
      delete split_receipt_item_url(@receipt_item.split, @receipt_item)
    end
    assert_redirected_to split_path(@receipt_item.split)
  end

  test "should not allow access to other users' receipt items" do
    patch split_receipt_item_url(splits(:two), receipt_items(:two)), params: { split_mode: "mine" }
    assert_response :not_found
  end
end
