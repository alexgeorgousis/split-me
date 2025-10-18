class ReceiptItem < ApplicationRecord
  belongs_to :receipt

  enum :split_mode, [ :mine, :shared, :undecided ], default: :undecided

  def my_share
    case
    when mine? then price
    when shared? then price / 2
    when undecided? then 0.0
    end
  end

  def their_share
    price - my_share
  end

  def favourite?
    Favourite.owned_by_user.exists? name: name
  end
end
