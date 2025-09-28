class AddSplitModeToReceiptItems < ActiveRecord::Migration[8.0]
  def change
    add_column :receipt_items, :split_mode, :integer, default: 0
  end
end
