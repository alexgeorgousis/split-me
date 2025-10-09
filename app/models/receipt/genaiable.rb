module Receipt::Genaiable
  extend ActiveSupport::Concern

  included do
    require "net/http"
    require "json"
  end

  def llm_magic(text)
    return [] unless text.present?

    prompt = <<~PROMPT
      Parse this Sainsbury's grocery receipt and extract only the grocery items as JSON.

      For each grocery item, provide:
      - name: Clean product name (remove "Sainsbury's", "Own Brand", "Taste the Difference", etc.)
      - price: Total price for this line item exactly as shown on receipt

      Rules:
      - Skip headers, footers, store info, payment details, and promotional text
      - Skip substitution explanations and "substituted with" lines
      - Use the total price shown for each line (e.g., for "5 Greek Yogurt £5.50", use 5.50 as the price)
      - Only include actual grocery products that were purchased
      - Clean product names by removing store branding

      Receipt text:
      #{text}

      Return only a valid JSON array with no other text:
      [{"name": "Product Name", "price": 5.50}]
    PROMPT

    api_response = call_claude_api(prompt)
    raise "No response from Claude API" unless api_response

    json_text = api_response.strip
    json_text = json_text.gsub(/^```json\s*/, "").gsub(/\s*```$/, "")

    json_start = json_text.index("[")
    if json_start
      json_text = json_text[json_start..-1]
    end

    parsed_items = JSON.parse(json_text)

    result = parsed_items.map do |item|
      price = if item["price"]
        item["price"].to_f
      elsif item["unit_price"] && item["quantity"]
        item["unit_price"].to_f * item["quantity"].to_i
      else
        0.0
      end

      {
        name: item["name"],
        price: price
      }
    end
    result
  end

  private

  def call_claude_api(prompt)
    uri = URI("https://api.anthropic.com/v1/messages")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    store = OpenSSL::X509::Store.new
    store.set_default_paths
    http.cert_store = store

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = ENV["ANTHROPIC_API_KEY"]
    request["anthropic-version"] = "2023-06-01"

    request.body = JSON.generate({
      model: "claude-3-haiku-20240307",
      max_tokens: 4000,
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
      raise "Claude API error: #{response.code} #{response.body}"
    end
  rescue => e
    Rails.logger.error "Claude API request failed: #{e.message}"
    raise "Claude API request failed: #{e.message}"
  end
end
