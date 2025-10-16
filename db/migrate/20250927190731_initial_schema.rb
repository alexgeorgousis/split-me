class InitialSchema < ActiveRecord::Migration[8.1]
  def change
    create_table :active_storage_attachments do |t|
      t.bigint :blob_id, null: false
      t.datetime :created_at, null: false
      t.string :name, null: false
      t.bigint :record_id, null: false
      t.string :record_type, null: false
      t.index [ :blob_id ], name: "index_active_storage_attachments_on_blob_id"
      t.index [ :record_type, :record_id, :name, :blob_id ], name: "index_active_storage_attachments_uniqueness", unique: true
    end

    create_table :active_storage_blobs do |t|
      t.bigint :byte_size, null: false
      t.string :checksum
      t.string :content_type
      t.datetime :created_at, null: false
      t.string :filename, null: false
      t.string :key, null: false
      t.text :metadata
      t.string :service_name, null: false
      t.index [ :key ], name: "index_active_storage_blobs_on_key", unique: true
    end

    create_table :active_storage_variant_records do |t|
      t.bigint :blob_id, null: false
      t.string :variation_digest, null: false
      t.index [ :blob_id, :variation_digest ], name: "index_active_storage_variant_records_uniqueness", unique: true
    end

    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.timestamps
      t.index [ :email_address ], unique: true
    end

    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end

    create_table :splits do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total
      t.timestamps
    end

    create_table :favourites do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.timestamps
    end

    create_table :receipts do |t|
      t.references :split, null: false, foreign_key: true
      t.timestamps
    end

    create_table :receipt_items do |t|
      t.references :receipt, null: false, foreign_key: true
      t.string :name
      t.decimal :price, default: 0.0, null: false
      t.boolean :selected, default: false, null: false
      t.integer :split_mode, default: 0
      t.timestamps
    end

    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id
  end
end
