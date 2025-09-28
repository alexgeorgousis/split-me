require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @order = orders(:one)
  end

  test "should create order" do
    visit orders_url
    click_on "New order"

    attach_file "order_receipt_attributes_file", Rails.root.join("test", "fixtures", "files", "test_receipt.pdf")
    click_on "Create Order"

    assert_text "Order was successfully created"
    assert_current_path orders_path
  end

  test "should update Order" do
    visit order_url(@order)
    click_on "Edit this order", match: :first

    click_on "Update Order"

    assert_text "Order was successfully updated"
    click_on "Back"
  end

  test "should destroy Order" do
    visit order_url(@order)
    accept_confirm { click_on "Destroy this order", match: :first }

    assert_text "Order was successfully destroyed"
  end
end
