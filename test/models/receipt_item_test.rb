require "test_helper"

class ReceiptItemTest < ActiveSupport::TestCase
  setup do
    @mine = receipt_items(:mine)
    @shared = receipt_items(:shared)
    @undecided = receipt_items(:undecided)
  end

  test "calculates my share correctly" do
    assert_equal 10, @mine.my_share
    assert_equal 10, @shared.my_share
    assert_equal 0, @undecided.my_share
  end

  test "calculates their share correctly" do
    assert_equal 0, @mine.their_share
    assert_equal 10, @shared.their_share
    assert_equal 30, @undecided.their_share
  end
end
