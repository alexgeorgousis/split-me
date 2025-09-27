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

    def file
      @file ||= MockReceipt.new
    end

    def receipt_items
      MockReceiptItems.new(@receipt_items_data)
    end

    def extract_text_from_receipt
      sample_text
    end

    def parse_sainsburys_items(text)
      [
        { name: "Test Milk", price: 1.40 },
        { name: "Test Bread", price: 2.50 }
      ]
    end

    def receipt_processed?
      processed?
    end

    def order
      @order ||= MockOrder.new
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

    def build(attrs)
      MockReceiptItem.new(attrs, @data)
    end

    def any?
      @data.any?
    end

    def count
      @data.count
    end

    def sum
      @data.sum { |item| item[:price] }
    end
  end

  class MockReceiptItem
    attr_reader :name, :price, :errors

    def initialize(attrs, data_array)
      @name = attrs[:name]
      @price = attrs[:price]
      @data_array = data_array
      @errors = MockErrors.new
    end

    def save
      @data_array << { name: @name, price: @price }
      true
    end
  end

  class MockErrors
    def full_messages
      []
    end
  end

  class MockOrder
    def auto_match_all_ingredients!
      0
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

    bread_item = @order.receipt_items_data.find { |item| item[:name] == "Test Bread" }
    assert_not_nil bread_item
    assert_equal 2.50, bread_item[:price]
  end

  test "process_receipt! returns false when no receipt attached" do
    @order.file.define_singleton_method(:attached?) { false }
    result = @order.process_receipt!
    assert_not result
  end

  test "process_receipt! clears existing receipt items before creating new ones" do
    # Add some existing items
    @order.receipt_items_data << { name: "Old Item", price: 1.0 }

    @order.process_receipt!

    # Should have new items, not old ones
    assert_equal 2, @order.receipt_items_data.length
    assert_nil @order.receipt_items_data.find { |item| item[:name] == "Old Item" }
  end

  test "receipt_processed? returns true when receipt items exist" do
    @order.receipt_items_data << { name: "Test", price: 1.0 }

    assert @order.receipt_processed?
  end

  test "receipt_processed? returns false when no receipt items" do
    assert_not @order.receipt_processed?
  end

  test "receipt_total_from_items calculates correct total" do
    @order.receipt_items_data = [
      { name: "Item 1", price: 1.40 },
      { name: "Item 2", price: 2.50 }
    ]

    expected_total = 1.40 + 2.50
    assert_equal expected_total, @order.receipt_total_from_items
  end

  test "receipt_items_count returns correct count" do
    @order.receipt_items_data = [
      { name: "Item 1", price: 1.0 },
      { name: "Item 2", price: 2.0 }
    ]

    assert_equal 2, @order.receipt_items_count
  end
end
