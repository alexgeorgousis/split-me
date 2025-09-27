class CreateCompleteSchema < ActiveRecord::Migration[8.0]
  def change
    # App tables
    create_table :orders do |t|
      t.decimal :total
      t.timestamps null: false
    end

    create_table :meals do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :meals_orders, id: false do |t|
      t.integer :order_id, null: false
      t.integer :meal_id, null: false
      t.index [ :meal_id ], name: "index_meals_orders_on_meal_id"
      t.index [ :order_id ], name: "index_meals_orders_on_order_id"
    end

    create_table :receipts do |t|
      t.integer :order_id, null: false
      t.timestamps null: false
      t.index [ :order_id ], name: "index_receipts_on_order_id"
    end

    create_table :receipt_items do |t|
      t.string :name
      t.decimal :price
      t.integer :receipt_id, null: false
      t.boolean :selected, default: false, null: false
      t.timestamps null: false
      t.index [ :receipt_id ], name: "index_receipt_items_on_receipt_id"
    end

    create_table :ingredients do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :ingredient_matches do |t|
      t.integer :receipt_item_id, null: false
      t.integer :ingredient_id, null: false
      t.decimal :confidence
      t.timestamps null: false
      t.index [ :ingredient_id ], name: "index_ingredient_matches_on_ingredient_id"
      t.index [ :receipt_item_id ], name: "index_ingredient_matches_on_receipt_item_id"
    end

    create_table :meal_ingredients do |t|
      t.integer :meal_id, null: false
      t.integer :ingredient_id, null: false
      t.timestamps null: false
      t.index [ :ingredient_id ], name: "index_meal_ingredients_on_ingredient_id"
      t.index [ :meal_id ], name: "index_meal_ingredients_on_meal_id"
    end

    # Active Storage tables
    create_table :active_storage_blobs do |t|
      t.string :key, null: false
      t.string :filename, null: false
      t.string :content_type
      t.text :metadata
      t.string :service_name, null: false
      t.bigint :byte_size, null: false
      t.string :checksum
      t.datetime :created_at, null: false
      t.index [ :key ], name: "index_active_storage_blobs_on_key", unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string :name, null: false
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.bigint :blob_id, null: false
      t.datetime :created_at, null: false
      t.index [ :blob_id ], name: "index_active_storage_attachments_on_blob_id"
      t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
    end

    create_table :active_storage_variant_records do |t|
      t.bigint :blob_id, null: false
      t.string :variation_digest, null: false
      t.index [ :blob_id, :variation_digest ], name: "index_active_storage_variant_records_uniqueness", unique: true
    end

    # Foreign keys
    add_foreign_key :receipts, :orders
    add_foreign_key :receipt_items, :receipts
    add_foreign_key :ingredient_matches, :ingredients
    add_foreign_key :ingredient_matches, :receipt_items
    add_foreign_key :meal_ingredients, :ingredients
    add_foreign_key :meal_ingredients, :meals
    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end
end
