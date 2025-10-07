module Receipt::Processable
  extend ActiveSupport::Concern

  def process_receipt!
    Rails.logger.info "Checking if receipt is attached..."
    unless file.attached?
      Rails.logger.error "Receipt not attached"
      return false
    end
    Rails.logger.info "Receipt is attached"

    Rails.logger.info "Extracting text from receipt..."
    text = extract_text_from_receipt
    unless text.present?
      Rails.logger.error "No text extracted from receipt"
      return false
    end
    Rails.logger.info "Text extracted: #{text.length} characters"

    Rails.logger.info "Parsing Sainsbury's items..."
    items_data = parse_sainsburys_items(text)
    if items_data.empty?
      Rails.logger.error "No items parsed from receipt"
      return false
    end
    Rails.logger.info "Parsed #{items_data.length} items"

    create_receipt_items!(items_data)

    true
  rescue => e
    Rails.logger.error "Failed to process receipt: #{e.message}"
    false
  end

  def create_receipt_items!(items_data)
    Rails.logger.info "Creating #{items_data.length} receipt items"

    # Clear existing receipt items to avoid duplicates
    receipt_items.destroy_all

    items_data.each_with_index do |item_data, index|
      Rails.logger.info "Creating item #{index + 1}: #{item_data.inspect}"

      item = receipt_items.build(
        name: item_data[:name],
        price: item_data[:price]
      )

      unless item.save
        Rails.logger.error "Failed to save receipt item: #{item.errors.full_messages.join(', ')}"
        raise "Failed to save receipt item: #{item.errors.full_messages.join(', ')}"
      end

      Rails.logger.info "Successfully created item: #{item.name} - £#{item.price}"
    end

    Rails.logger.info "Successfully created all #{items_data.length} receipt items"
  end

  def processed?
    receipt_items.any?
  end

  def receipt_total_from_items
    receipt_items.sum(&:price)
  end

  def receipt_items_count
    receipt_items.count
  end
end
