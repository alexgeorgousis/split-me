class CreateIngredientMatches < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredient_matches do |t|
      t.references :receipt_item, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.decimal :confidence

      t.timestamps
    end
  end
end
