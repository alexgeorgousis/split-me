class Receipt::ProcessJob < ApplicationJob
  queue_as :default

  def perform(receipt)
    return unless receipt.pending? || receipt.failed?

    receipt.processing!
    broadcast_split(receipt)

    receipt.process_now
    receipt.processed!
    broadcast_split(receipt)

  rescue => e
    Rails.logger.error "Receipt processing failed: #{e.class} - #{e.message}"
    receipt.failed!
    broadcast_split(receipt)
  end

  private

  def broadcast_split(receipt)
    receipt.split.broadcast_replace_to :splits
  end
end
