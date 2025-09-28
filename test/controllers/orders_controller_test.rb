require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get orders_url
    assert_response :success
  end

  test "should get new" do
    get new_order_url
    assert_response :success
  end

  test "should create order" do
    assert_difference("Order.count") do
      post orders_url, params: { order: { meal_ids: [], receipt_attributes: { file: fixture_file_upload("test_receipt.pdf", "application/pdf") } } }
    end

    assert_redirected_to orders_url
  end

  test "should create order with receipt" do
    assert_difference([ "Order.count", "Receipt.count" ]) do
      post orders_url, params: { order: { meal_ids: [], receipt_attributes: { file: fixture_file_upload("test_receipt.pdf", "application/pdf") } } }
    end

    order = Order.last
    assert order.receipt.present?
    assert order.receipt.file.attached?
    assert_equal "test_receipt.pdf", order.receipt.file.filename.to_s
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order), params: { order: { meal_ids: [] } }
    assert_redirected_to orders_url
  end

  test "should destroy order" do
    assert_difference("Order.count", -1) do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
  end

  test "should process receipt successfully" do
    order = Order.create!(receipt_attributes: { file: fixture_file_upload("test_receipt.pdf", "application/pdf") })

    post process_receipt_order_url(order)

    assert_redirected_to order_url(order)
    assert_equal "Receipt processed successfully!", flash[:notice]

    order.reload
    assert order.receipt_processed?
    assert order.receipt_items.any?
    assert order.receipt_items.count > 0
  end

  test "should handle API response with explanatory text" do
    receipt = Receipt.new
    response_with_text = "Here is the JSON array of the grocery items:\n\n[{\"name\": \"Test Item\", \"price\": 1.50}]"

    # Mock the API call to return response with explanatory text
    receipt.define_singleton_method(:call_claude_api) { |prompt| response_with_text }

    items = receipt.send(:parse_sainsburys_items, "dummy text")

    assert_equal 1, items.length
    assert_equal "Test Item", items.first[:name]
    assert_equal 1.50, items.first[:price]
  end

  test "should fail to process receipt when no receipt attached" do
    order = Order.create!

    post process_receipt_order_url(order)

    assert_redirected_to order_url(order)
    assert_equal "Failed to process receipt. Please check the file format.", flash[:alert]
  end
end
