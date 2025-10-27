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

  test "should create split" do
    assert_difference("Split.count", +1) do
      post splits_url
    end

    assert_redirected_to splits_url
  end

  test "should process receipt when split is created" do
    mock_llm_response = Struct.new(:content).new({
      "items" => [
        { "name" => "Test Item", "price" => 1.50 },
        { "name" => "Another Item", "price" => 2.50 }
      ]
    })

    Receipt.prepend(Module.new do
      define_method(:ask_llm) { |_raw_receipt_text = nil| mock_llm_response }
    end)

    perform_enqueued_jobs do
      post splits_url, params: { split: { receipt_attributes: { file: fixture_file_upload("test_receipt.pdf", "application/pdf") } } }
    end

    split = Split.last
    assert split.receipt.processed?
    assert_equal 2, split.receipt.receipt_items.count
  end

  test "should show split" do
    get split_url(@split)
    assert_response :success
  end

  test "should destroy split" do
    assert_difference("Split.count", -1) do
      delete split_url(@split)
    end

    assert_redirected_to splits_url
  end

  test "should not allow access to other users' splits" do
    get split_url(splits(:two))
    assert_response :not_found
  end
end
