class ReceiptItem < ApplicationRecord
  belongs_to :receipt

  delegate :split, to: :receipt

  after_create_commit do
    mine! if favourite?
  end

  enum :split_mode, [ :mine, :shared, :undecided ], default: :undecided

  def favourite?
    receipt.split.user.favourites.exists? name: name
  end

  def my_share
    case
    when mine? then price.round(2)
    when shared? then (price / 2).round(2)
    when undecided? then 0.0
    end
  end

  def their_share
    (price - my_share).round(2)
  end
end
