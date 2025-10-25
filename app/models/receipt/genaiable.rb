module Receipt::Genaiable
  extend ActiveSupport::Concern

  def create_receipt_items_using_llm_magic
    receipt_items.create! llm_magic["items"]
  rescue StandardError => e
    Rails.logger.error "LLM failed to parse receipt: #{e.message}"
    raise "Failed to parse receipt using LLM."
  end

  private
    def llm_magic
      if file.content_type == "application/pdf"
        ask_llm(parse_attached_file).content
      else
        ask_llm.content
      end
    end

    def ask_llm(raw_receipt_text = nil)
      chat = RubyLLM.chat(model: "gpt-5-nano")
      chat.with_schema(ReceiptItemsSchema)

      if raw_receipt_text.present?
        chat.ask(prompt raw_receipt_text)
      else
        chat.ask(prompt, with: file)
      end
    end

    def prompt(raw_receipt_text = nil)
      <<~PROMPT
        Parse this receipt and extract only the line items.

        For each line item, provide:
        - name
        - price: Total price for this line item exactly as shown on receipt

        Rules:
        - Skip headers, footers, store info, payment details, and promotional text
        - For Sainsbury's receipts, ignore Substitutions and Shorter life sections

        #{raw_receipt_text if raw_receipt_text.present?}
      PROMPT
    end
end
