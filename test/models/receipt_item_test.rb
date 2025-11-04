require "test_helper"

class ReceiptItemTest < ActiveSupport::TestCase
  setup do
    @mine = receipt_items(:mine)
    @shared = receipt_items(:shared)
    @undecided = receipt_items(:undecided)
  end

  test "calculating shares" do
    assert_equal 10, @mine.my_share
    assert_equal 10, @shared.my_share
    assert_equal 0, @undecided.my_share

    assert_equal 0, @mine.their_share
    assert_equal 10, @shared.their_share
    assert_equal 30, @undecided.their_share
  end

  test "creating a receipt item that matches a favourite will automatically mark it as mine" do
    item = ReceiptItem.create! receipt: receipts(:one), name: "one", price: 15
    assert item.mine?
  end
end
