class Receipt < ApplicationRecord
  include Receipt::Parsable
  include Receipt::Processable

  belongs_to :order
  has_many :receipt_items, dependent: :destroy
  has_one_attached :file

  delegate :attached?, :filename, :blob, to: :file, allow_nil: true

  private

  def process
    if file.attached?
      Rails.logger.info "Processing receipt #{id} for order #{order.id}"

        # if params[:auto_match]
        #   matches_count = @order.auto_match_all_ingredients!
        #   redirect_to review_receipt_order_path(@order), notice: "Auto-matched #{matches_count} ingredients!"
        # else
        begin
          if process_receipt!
            Rails.logger.info "Receipt processed successfully"
            redirect_to review_receipt_order_path(@order), notice: "Receipt processed successfully!"
          else
            Rails.logger.error "Receipt processing failed"
            redirect_to @order, alert: "Failed to process receipt. Please check the file format."
          end
        rescue => e
          Rails.logger.error "Exception during receipt processing: #{e.class} - #{e.message}"
          redirect_to @order, alert: "Failed to process receipt: #{e.message}"
        end
      # end
    end
  end
end
