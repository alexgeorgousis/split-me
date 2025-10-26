class Receipt::ProcessJob < ApplicationJob
  queue_as :default

  def perform(receipt)
    return unless receipt.pending? || receipt.failed?

    receipt.processing!
    receipt.split.broadcast_update_split_card_content

    receipt.process_now
    receipt.processed!
    receipt.split.broadcast_update_split_card_content

  rescue => e
    Rails.logger.error "Receipt processing failed: #{e.class} - #{e.message}"
    receipt.failed!
    receipt.split.broadcast_update_split_card_content
  end
end
