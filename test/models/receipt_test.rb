require "test_helper"

class ReceiptTest < ActiveSupport::TestCase
  setup do
    @receipt = receipts(:one)
  end

  test "calculates total correctly" do
    assert_equal 60, @receipt.total
  end

  test "calculates my total correctly" do
    assert_equal 20, @receipt.my_total
  end

  test "calculates their total correctly" do
    assert_equal 40, @receipt.their_total
  end
end
