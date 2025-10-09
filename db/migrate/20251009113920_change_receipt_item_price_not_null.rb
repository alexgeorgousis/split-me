class ChangeReceiptItemPriceNotNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :receipt_items, :price, false, 0
  end
end
