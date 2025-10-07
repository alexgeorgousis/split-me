class DropMealAndIngredientTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :ingredient_matches do |t|
      t.integer :receipt_item_id, null: false
      t.integer :ingredient_id, null: false
      t.decimal :confidence
      t.timestamps null: false
      t.index [ :ingredient_id ], name: "index_ingredient_matches_on_ingredient_id"
      t.index [ :receipt_item_id ], name: "index_ingredient_matches_on_receipt_item_id"
    end

    drop_table :meal_ingredients do |t|
      t.integer :meal_id, null: false
      t.integer :ingredient_id, null: false
      t.timestamps null: false
      t.index [ :ingredient_id ], name: "index_meal_ingredients_on_ingredient_id"
      t.index [ :meal_id ], name: "index_meal_ingredients_on_meal_id"
    end

    drop_table :meals_orders, id: false do |t|
      t.integer :order_id, null: false
      t.integer :meal_id, null: false
      t.index [ :meal_id ], name: "index_meals_orders_on_meal_id"
      t.index [ :order_id ], name: "index_meals_orders_on_order_id"
    end

    drop_table :ingredients do |t|
      t.string :name
      t.timestamps null: false
    end

    drop_table :meals do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
