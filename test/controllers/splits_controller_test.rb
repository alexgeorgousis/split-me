require "test_helper"

class SplitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @split = splits(:one)
    sign_in_as users(:one)
  end

  test "should get index" do
    get splits_url
    assert_response :success
  end

  test "should get new" do
    get new_split_url
    assert_response :success
  end

  test "should create split" do
    assert_difference("Split.count") do
      post splits_url, params: { split: { meal_ids: [], receipt_attributes: { file: fixture_file_upload("test_receipt.pdf", "application/pdf") } } }
    end

    assert_redirected_to splits_url
  end

  test "should create split with receipt" do
    assert_difference([ "Split.count", "Receipt.count" ]) do
      post splits_url, params: { split: { meal_ids: [], receipt_attributes: { file: fixture_file_upload("test_receipt.pdf", "application/pdf") } } }
    end

    split = Split.last
    assert split.receipt.present?
    assert split.receipt.file.attached?
    assert_equal "test_receipt.pdf", split.receipt.file.filename.to_s
  end

  test "should show split" do
    get split_url(@split)
    assert_response :success
  end

  test "should get edit" do
    get edit_split_url(@split)
    assert_response :success
  end

  test "should update split" do
    patch split_url(@split), params: { split: { meal_ids: [] } }
    assert_redirected_to splits_url
  end

  test "should destroy split" do
    assert_difference("Split.count", -1) do
      delete split_url(@split)
    end

    assert_redirected_to splits_url
  end

  test "should process receipt successfully" do
    split = Split.create!(receipt_attributes: { file: fixture_file_upload("test_receipt.pdf", "application/pdf") })

    response_json = "[{\"name\": \"Test Item\", \"price\": 1.50}, {\"name\": \"Another Item\", \"price\": 2.50}]"
    mock_response = Struct.new(:content).new(response_json)

    Receipt.prepend(Module.new do
      define_method(:ask_llm) { |raw_receipt_text = nil| mock_response }
    end)

    post process_receipt_split_url(split)

    assert_redirected_to split_url(split)
    assert_equal "Receipt processed successfully!", flash[:notice]

    split.reload
    assert split.receipt.processed?
    assert_equal 2, split.receipt.receipt_items.count
  end

  test "should fail to process receipt when no receipt attached" do
    split = Split.create!

    post process_receipt_split_url(split)

    assert_redirected_to splits_url
    assert_equal "No receipt file attached.", flash[:alert]
  end
end
