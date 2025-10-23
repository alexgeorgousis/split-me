class RemoveDefaultFromSplitModeAndAddNullConstraint < ActiveRecord::Migration[8.1]
  def change
    change_column_default :receipt_items, :split_mode, from: "undecided", to: nil
    change_column_null :receipt_items, :split_mode, false
  end
end
