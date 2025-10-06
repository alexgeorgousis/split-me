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

    response_json = "[{\"name\": \"Test Item\", \"price\": 1.50}, {\"name\": \"Another Item\", \"price\": 2.50}]"

    Receipt.prepend(Module.new do
      define_method(:call_claude_api) { |prompt| response_json }
    end)

    post process_receipt_order_url(order)

    assert_redirected_to order_url(order)
    assert_equal "Receipt processed successfully!", flash[:notice]

    order.reload
    assert order.receipt.processed?
    assert_equal 2, order.receipt.receipt_items.count
  end

  test "should fail to process receipt when no receipt attached" do
    order = Order.create!

    post process_receipt_order_url(order)

    assert_redirected_to orders_url
    assert_equal "No receipt file attached.", flash[:alert]
  end
end
