require "application_system_test_case"

class SplitsTest < ApplicationSystemTestCase
  setup do
    @split = splits(:one)
  end

  test "should create split" do
    visit splits_url

    attach_file "receipt-upload", Rails.root.join("test", "fixtures", "files", "test_receipt.pdf"), make_visible: true

    assert_text "Split was successfully created"
    assert_current_path splits_path
  end

  test "should update Split" do
    visit splits_url
    find("a[href='#{edit_split_path(@split)}']").click

    click_on "Update Split"

    assert_text "Split was successfully updated"
    assert_current_path splits_path
  end

  test "should destroy Split" do
    visit splits_url
    accept_confirm { find("form[action*='#{@split.id}'][method='post'] button").click }

    assert_text "Split was successfully destroyed"
  end
end
