class Receipt < ApplicationRecord
  include Receipt::Parsable
  include Receipt::Genaiable

  belongs_to :order
  has_many :receipt_items, dependent: :destroy
  has_one_attached :file

  delegate :attached?, :filename, :blob, to: :file, allow_nil: true

  def process_receipt!
    text = parse_attached_file
    items = llm_magic text
    create_receipt_items! items
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
    def create_receipt_items!(items_data)
      # Clear existing receipt items to avoid duplicates
      receipt_items.destroy_all

      items_data.each_with_index do |item_data, index|
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
