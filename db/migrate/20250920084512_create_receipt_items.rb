class CreateReceiptItems < ActiveRecord::Migration[8.0]
  def change
    create_table :receipt_items do |t|
      t.string :name
      t.decimal :price
      t.decimal :quantity
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
