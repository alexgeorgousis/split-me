class Split < ApplicationRecord
  include Splittable

  belongs_to :user
  has_one :receipt, dependent: :destroy
  accepts_nested_attributes_for :receipt, allow_destroy: true

  delegate :processed?, to: :receipt, prefix: true, allow_nil: true
  delegate :receipt_total, :receipt_items_count, to: :receipt, allow_nil: true

  def self.owned_by_user(user: Current.user)
    user.splits
  end

  def process_receipt!
    receipt.process!
  end
end
