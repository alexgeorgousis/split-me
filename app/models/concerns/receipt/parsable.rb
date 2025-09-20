module Receipt::Parsable
  extend ActiveSupport::Concern

  included do
    require 'pdf-reader'
    require 'timeout'
  end

  def extract_text_from_receipt
    return nil unless receipt.attached?

    Timeout.timeout(30) do
      receipt.blob.open do |file|
        reader = PDF::Reader.new(file)
        text_pages = reader.pages.first(5).map(&:text)
        text_pages.join("\n")
      end
    end
  rescue Timeout::Error
    Rails.logger.error "PDF processing timed out after 30 seconds"
    nil
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
    Rails.logger.error "PDF format error: #{e.message}"
    nil
  rescue => e
    Rails.logger.error "Failed to extract text from receipt: #{e.message}"
    nil
  end

  def parse_sainsburys_items(text)
    return [] unless text.present?

    items = []
    lines = text.split("\n").map(&:strip).reject(&:blank?)

    # Sainsbury's receipt pattern: item name on one line, price on next line
    i = 0
    while i < lines.length - 1
      current_line = lines[i]
      next_line = lines[i + 1]

      # Skip header/footer content
      next if skip_line?(current_line)

      # Look for price pattern on the next line
      if price_match = next_line.match(/£(\d+\.\d{2})/)
        price = price_match[1].to_f

        # Extract quantity if present (e.g., "2 x Item Name")
        quantity = 1
        item_name = current_line

        if quantity_match = current_line.match(/^(\d+)\s*x\s*(.+)$/i)
          quantity = quantity_match[1].to_i
          item_name = quantity_match[2].strip
        end

        items << {
          name: clean_item_name(item_name),
          price: price,
          quantity: quantity
        }

        i += 2 # Skip both lines
      else
        i += 1
      end
    end

    items
  end

  private

  def skip_line?(line)
    skip_patterns = [
      /sainsbury/i,
      /store\s*\d+/i,
      /tel:/i,
      /\d{2}\/\d{2}\/\d{4}/,
      /card\s*payment/i,
      /total/i,
      /change/i,
      /receipt/i,
      /thank\s*you/i
    ]

    skip_patterns.any? { |pattern| line.match?(pattern) }
  end

  def clean_item_name(name)
    # Remove common prefixes/suffixes and clean up
    name.gsub(/^(own\s*brand|sainsbury.?s)\s*/i, '')
        .gsub(/\s*(organic|free\s*range)\s*/i, ' ')
        .strip
        .squeeze(' ')
  end
end