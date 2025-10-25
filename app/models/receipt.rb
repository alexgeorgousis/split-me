class Receipt < ApplicationRecord
  include Parsable
  include Genaiable

  belongs_to :split
  has_many :receipt_items, dependent: :destroy
  has_one_attached :file

  delegate :attached?, :filename, :blob, to: :file, allow_nil: true

  def process
    create_receipt_items_using_llm_magic
  end

  def processed?
    receipt_items.any?
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
