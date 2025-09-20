require "test_helper"

class Receipt::ProcessableTest < ActiveSupport::TestCase
  class TestOrder
    include Receipt::Parsable
    include Receipt::Processable

    attr_accessor :receipt_items_data

    def initialize
      @receipt_items_data = []
    end

    def receipt
      @receipt ||= MockReceipt.new
    end

    def receipt_items
      MockReceiptItems.new(@receipt_items_data)
    end

    def extract_text_from_receipt
      sample_text
    end

    def parse_sainsburys_items(text)
      [
        { name: "Test Milk", price: 1.40, quantity: 1 },
        { name: "Test Bread", price: 2.50, quantity: 2 }
      ]
    end

    private

    def sample_text
      "1 Test Milk £1.40\n2 Test Bread £2.50"
    end
  end

  class MockReceipt
    def attached?
      true
    end
  end

  class MockReceiptItems
    def initialize(data)
      @data = data
    end

    def destroy_all
      @data.clear
    end

    def create!(attrs)
      @data << attrs
    end

    def any?
      @data.any?
    end

    def count
      @data.count
    end

    def sum
      @data.sum { |item| item[:price] * item[:quantity] }
    end
  end

  setup do
    @order = TestOrder.new
  end

  test "process_receipt! creates receipt items from parsed data" do
    result = @order.process_receipt!

    assert result, "Should return true on successful processing"
    assert_equal 2, @order.receipt_items_data.length

    milk_item = @order.receipt_items_data.find { |item| item[:name] == "Test Milk" }
    assert_not_nil milk_item
    assert_equal 1.40, milk_item[:price]
    assert_equal 1, milk_item[:quantity]

    bread_item = @order.receipt_items_data.find { |item| item[:name] == "Test Bread" }
    assert_not_nil bread_item
    assert_equal 2.50, bread_item[:price]
    assert_equal 2, bread_item[:quantity]
  end

  test "process_receipt! returns false when no receipt attached" do
    @order.receipt.define_singleton_method(:attached?) { false }
    result = @order.process_receipt!
    assert_not result
  end

  test "process_receipt! clears existing receipt items before creating new ones" do
    # Add some existing items
    @order.receipt_items_data << { name: "Old Item", price: 1.0, quantity: 1 }

    @order.process_receipt!

    # Should have new items, not old ones
    assert_equal 2, @order.receipt_items_data.length
    assert_nil @order.receipt_items_data.find { |item| item[:name] == "Old Item" }
  end

  test "receipt_processed? returns true when receipt items exist" do
    @order.receipt_items_data << { name: "Test", price: 1.0, quantity: 1 }

    assert @order.receipt_processed?
  end

  test "receipt_processed? returns false when no receipt items" do
    assert_not @order.receipt_processed?
  end

  test "receipt_total_from_items calculates correct total" do
    @order.receipt_items_data = [
      { name: "Item 1", price: 1.40, quantity: 1 },
      { name: "Item 2", price: 2.50, quantity: 2 }
    ]

    expected_total = (1.40 * 1) + (2.50 * 2)
    assert_equal expected_total, @order.receipt_total_from_items
  end

  test "receipt_items_count returns correct count" do
    @order.receipt_items_data = [
      { name: "Item 1", price: 1.0, quantity: 1 },
      { name: "Item 2", price: 2.0, quantity: 1 }
    ]

    assert_equal 2, @order.receipt_items_count
  end
end