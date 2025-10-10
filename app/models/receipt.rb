class Receipt < ApplicationRecord
  include Receipt::Parsable
  include Receipt::Genaiable

  belongs_to :split
  has_many :receipt_items, dependent: :destroy
  has_one_attached :file

  delegate :attached?, :filename, :blob, to: :file, allow_nil: true

  def process_receipt!
    create_receipt_items_using llm_magic
  end

  def processed?
    receipt_items.any?
  end

  def receipt_total
    receipt_items.sum(&:price)
  end

  def receipt_items_count
    receipt_items.count
  end

  private
    def create_receipt_items_using(receipt_item_hashes)
      # Clear existing receipt items to avoid duplicates
      receipt_items.destroy_all

      receipt_item_hashes.each_with_index do |item_data, index|
        item = receipt_items.build(
          name: item_data[:name],
          price: item_data[:price]
        )

        item.selected = item.favourite?

        unless item.save
          raise "Failed to save receipt item: #{item.errors.full_messages.join(', ')}"
        end
      end
    end
end
