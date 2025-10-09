module Receipt::Genaiable
  extend ActiveSupport::Concern

  def llm_magic
    if file.content_type == "application/pdf"
      response = ask_llm parse_attached_file
    else
      response = ask_llm
    end

    receipt_items_json = to_json response.content
    receipt_items_json.map(&method(:receipt_item_hash_from))
  end

  private
    def ask_llm(raw_receipt_text = nil)
      chat = RubyLLM.chat(model: "claude-sonnet-4")
      if raw_receipt_text.present?
        chat.ask(prompt raw_receipt_text)
      else
        chat.ask prompt, with: file
      end
    end

    def prompt(raw_receipt_text = nil)
      <<~PROMPT
        Parse this receipt and extract only the grocery items as JSON.

        For each grocery item, provide:
        - name
        - price: Total price for this line item exactly as shown on receipt

        Rules:
        - Skip headers, footers, store info, payment details, and promotional text
        - For Sainsbury's receipts, ignore Substitutions and Shorter life sections
        - Clean product names by removing store branding

        Return only a valid JSON array with no other text:
        [{"name": "Product Name", "price": 5.50}]

        #{raw_receipt_text if raw_receipt_text.present?}
      PROMPT
    end

    def to_json(raw_llm_response)
      cleaned = raw_llm_response.gsub(/^```json\s*/, "").gsub(/\s*```$/, "")
      JSON.parse(cleaned)
    end

    def receipt_item_hash_from(receipt_item_json)
      { name: receipt_item_json["name"], price: receipt_item_json["price"].to_f }
    end
end
