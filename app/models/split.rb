class Split < ApplicationRecord
  belongs_to :user
  has_one :receipt, dependent: :destroy
  accepts_nested_attributes_for :receipt, allow_destroy: true

  delegate :receipt_items_count, to: :receipt, allow_nil: true

  def self.owned_by_user(user: Current.user)
    user.splits
  end

  def total
    receipt.total
  end

  def my_total
    receipt.my_total
  end

  def their_total
    receipt.their_total
  end

  def broadcast_update_split_card_content
    broadcast_replace_to self,
      target: [ self, :card_content ],
      partial: "splits/card_content",
      locals: { split: self }
  end
end
