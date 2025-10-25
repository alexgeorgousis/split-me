class ReceiptItemsSchema < RubyLLM::Schema
  array :items do
    object do
      string :name
      number :price
    end
  end
end
