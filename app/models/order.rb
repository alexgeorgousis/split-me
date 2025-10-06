class Order < ApplicationRecord
  include Splittable

  has_and_belongs_to_many :meals
  has_one :receipt, dependent: :destroy
  accepts_nested_attributes_for :receipt, allow_destroy: true

  delegate :processed?, to: :receipt, prefix: true, allow_nil: true
  delegate :receipt_total_from_items, :receipt_items_count, :process_receipt!, to: :receipt, allow_nil: true
end
