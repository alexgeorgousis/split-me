class Split < ApplicationRecord
  include Splittable

  has_one :receipt, dependent: :destroy
  accepts_nested_attributes_for :receipt, allow_destroy: true

  delegate :processed?, to: :receipt, prefix: true, allow_nil: true
  delegate :receipt_total, :receipt_items_count, to: :receipt, allow_nil: true

  def process_receipt!
    receipt.process!
  end
end
