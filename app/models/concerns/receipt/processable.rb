module Receipt::Processable
  extend ActiveSupport::Concern

  def process_receipt!
    return false unless receipt.attached?

    text = extract_text_from_receipt
    return false unless text.present?

    items_data = parse_sainsburys_items(text)
    return false if items_data.empty?

    create_receipt_items!(items_data)
    true
  rescue => e
    Rails.logger.error "Failed to process receipt: #{e.message}"
    false
  end

  def create_receipt_items!(items_data)
    # Clear existing receipt items to avoid duplicates
    receipt_items.destroy_all

    items_data.each do |item_data|
      receipt_items.create!(
        name: item_data[:name],
        price: item_data[:price],
        quantity: item_data[:quantity]
      )
    end
  end

  def receipt_processed?
    receipt_items.any?
  end

  def receipt_total_from_items
    receipt_items.sum { |item| item.price * item.quantity }
  end

  def receipt_items_count
    receipt_items.count
  end
end
