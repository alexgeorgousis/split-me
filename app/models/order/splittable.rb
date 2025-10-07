module Order::Splittable
  extend ActiveSupport::Concern

  def selected_receipt_total
    receipt.receipt_items.where(selected: true).sum(&:my_share_amount)
  end

  def their_receipt_total
    # TODO: There should be a receipt.total method to do this
    total = receipt.receipt_items.sum(:price)
    total - selected_receipt_total
  end
end
