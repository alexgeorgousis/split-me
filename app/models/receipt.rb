class Receipt < ApplicationRecord
  include Parsable
  include Genaiable

  belongs_to :split
  has_many :receipt_items, dependent: :destroy
  has_one_attached :file

  delegate :attached?, :filename, :blob, to: :file, allow_nil: true

  def process!
    create_receipt_items_using llm_magic
  end

  def processed?
    receipt_items.any?
  end

  def total
    receipt_items.sum(&:price)
  end

  def my_total
    receipt_items.sum(&:my_share)
  end

  def their_total
    receipt_items.sum(&:their_share)
  end

  def receipt_items_count
    receipt_items.count
  end

  private
    def create_receipt_items_using(receipt_item_hashes)
      receipt_item_hashes.each do |item_data|
        item = receipt_items.create! name: item_data[:name], price: item_data[:price]
        item.mine! if item.favourite?
      end
    end
end
