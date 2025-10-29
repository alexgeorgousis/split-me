class Receipt < ApplicationRecord
  include Parsable
  include Genaiable

  belongs_to :split
  has_many :receipt_items, dependent: :destroy

  has_one_attached :file
  validates :file,
    attached: true,
    content_type: [ "image/png", "image/jpeg", "image/webp", "application/pdf", "text/plain" ],
    size: { less_than: 20.megabytes }

  delegate :attached?, :filename, :blob, to: :file, allow_nil: true

  enum :status, [ :pending, :processing, :processed, :failed ], default: :pending

  def process_later
    Receipt::ProcessJob.perform_later self
  end

  def process_now
    create_receipt_items_using_llm_magic
  end

  def total
    receipt_items.sum(&:price)
  end

  def my_total
    receipt_items.sum(&:my_share)
  end

  def their_total
    receipt_items.sum(&:their_share)
  end

  def receipt_items_count
    receipt_items.count
  end
end
