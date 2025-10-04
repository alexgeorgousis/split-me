require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  setup do
    @order = orders(:one)
  end

  test "should create order" do
    visit orders_url

    attach_file "receipt-upload", Rails.root.join("test", "fixtures", "files", "test_receipt.pdf"), make_visible: true

    assert_text "Order was successfully created"
    assert_current_path orders_path
  end

  test "should update Order" do
    visit orders_url
    find("a[href='#{edit_order_path(@order)}']").click

    click_on "Update Order"

    assert_text "Order was successfully updated"
    assert_current_path orders_path
  end

  test "should destroy Order" do
    visit orders_url
    accept_confirm { find("form[action*='#{@order.id}'][method='post'] button").click }

    assert_text "Order was successfully destroyed"
  end
end
