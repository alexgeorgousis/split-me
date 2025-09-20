module Receipt::Parsable
  extend ActiveSupport::Concern

  included do
    require "pdf-reader"
    require "timeout"
    require "net/http"
    require "json"
  end

  def extract_text_from_receipt
    return nil unless receipt.attached?

    Rails.logger.info "Starting PDF text extraction for receipt"

    begin
      Rails.logger.info "Opening PDF file..."
      receipt.blob.open do |file|
        Rails.logger.info "Creating PDF reader..."
        reader = PDF::Reader.new(file)

        Rails.logger.info "PDF has #{reader.page_count} pages"
        return nil if reader.page_count == 0

        pages_to_process = [ reader.page_count, 3 ].min
        Rails.logger.info "Processing first #{pages_to_process} pages..."

        text_content = reader.pages.first(pages_to_process).map.with_index do |page, index|
          Rails.logger.info "Processing page #{index + 1}..."
          page.text
        end.join("\n")

        Rails.logger.info "Successfully extracted #{text_content.length} characters"
        text_content
      end
    rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
      Rails.logger.error "PDF format error: #{e.message}"
      nil
    rescue => e
      Rails.logger.error "Failed to extract text from receipt: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      nil
    end
  end

  def parse_sainsburys_items(text)
    return [] unless text.present?

    prompt = <<~PROMPT
      Parse this Sainsbury's grocery receipt and extract only the grocery items as JSON.

      For each grocery item, provide:
      - name: Clean product name (remove "Sainsbury's", "Own Brand", "Taste the Difference", etc.)
      - unit_price: Price per individual item (divide total price by quantity if needed)
      - quantity: Number of items purchased

      Rules:
      - Skip headers, footers, store info, payment details, and promotional text
      - Skip substitution explanations and "substituted with" lines
      - For lines like "5 Greek Yogurt £5.50", this means 5 items for £5.50 total, so unit_price = 1.10
      - Only include actual grocery products that were purchased
      - Clean product names by removing store branding

      Receipt text:
      #{text}

      Return only a valid JSON array with no other text:
      [{"name": "Product Name", "unit_price": 1.23, "quantity": 2}]
    PROMPT

    api_response = call_claude_api(prompt)
    return [] unless api_response

    # Extract JSON from the response, handling potential markdown formatting
    json_text = api_response.strip
    json_text = json_text.gsub(/^```json\s*/, "").gsub(/\s*```$/, "")

    parsed_items = JSON.parse(json_text)

    # Convert to the expected format with symbolized keys
    parsed_items.map do |item|
      {
        name: item["name"],
        price: item["unit_price"].to_f,
        quantity: item["quantity"].to_i
      }
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse Claude API JSON response: #{e.message}"
    Rails.logger.error "Response was: #{api_response}"
    []
  rescue => e
    Rails.logger.error "Error in parse_sainsburys_items: #{e.message}"
    []
  end

  private

  def call_claude_api(prompt)
    uri = URI("https://api.anthropic.com/v1/messages")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = ENV["ANTHROPIC_API_KEY"]
    request["anthropic-version"] = "2023-06-01"

    request.body = JSON.generate({
      model: "claude-3-haiku-20240307",
      max_tokens: 1000,
      messages: [
        {
          role: "user",
          content: prompt
        }
      ]
    })

    response = http.request(request)

    if response.code == "200"
      result = JSON.parse(response.body)
      result.dig("content", 0, "text")
    else
      Rails.logger.error "Claude API error: #{response.code} #{response.body}"
      nil
    end
  rescue => e
    Rails.logger.error "Claude API request failed: #{e.message}"
    nil
  end

  def skip_line?(line)
    skip_patterns = [
      /^sainsbury/i,  # Only skip lines that START with "sainsbury"
      /store\s*\d+/i,
      /tel:/i,
      /\d{2}\/\d{2}\/\d{4}/,
      /card\s*payment/i,
      /^total/i,      # Only skip lines that START with "total"
      /change/i,
      /your receipt/i,
      /thank\s*you/i,
      /slot time:/i,
      /our substitute/i,
      /our short life/i
    ]

    skip_patterns.any? { |pattern| line.match?(pattern) }
  end

  def clean_item_name(name)
    # Remove common prefixes/suffixes and clean up
    name.gsub(/^(own\s*brand|sainsbury.?s)\s*/i, "")
        .gsub(/\s*(organic|free\s*range)\s*/i, " ")
        .strip
        .squeeze(" ")
  end
end
