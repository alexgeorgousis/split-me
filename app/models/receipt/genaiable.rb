module Receipt::Genaiable
  extend ActiveSupport::Concern

  def llm_magic(text)
    return [] unless text.present?

    response = ask_llm(text)
    receipt_items_json = to_json(response.content)
    receipt_item_hashes = receipt_items_json.map(&method(:receipt_item_hash_from))
    receipt_item_hashes
  end

  private
    def ask_llm(text)
      chat = RubyLLM.chat(model: "claude-sonnet-4")
      chat.ask(prompt text)
    end

    def prompt(text)
      <<~PROMPT
        Parse this receipt and extract only the grocery items as JSON.

        For each grocery item, provide:
        - name
        - price: Total price for this line item exactly as shown on receipt

        Rules:
        - Skip headers, footers, store info, payment details, and promotional text
        - For Sainsbury's receipts, ignore Substitutions and Shorter life sections
        - Clean product names by removing store branding

        Receipt text:
        #{text}

        Return only a valid JSON array with no other text:
        [{"name": "Product Name", "price": 5.50}]
      PROMPT
    end

    def to_json(text)
      cleaned = text.gsub(/^```json\s*/, "").gsub(/\s*```$/, "")
      JSON.parse(cleaned)
    end

    def receipt_item_hash_from(receipt_item_json)
      { name: receipt_item_json["name"], price: receipt_item_json["price"].to_f }
    end
end
