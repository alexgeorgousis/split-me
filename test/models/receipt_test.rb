require "test_helper"

class ReceiptTest < ActiveSupport::TestCase
  setup do
    @receipt = receipts(:one)
  end

  test "calculating totals" do
    assert_equal 60, @receipt.total
    assert_equal 20, @receipt.my_total
    assert_equal 40, @receipt.their_total
  end
end
