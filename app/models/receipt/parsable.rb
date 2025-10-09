module Receipt::Parsable
  extend ActiveSupport::Concern

  included do
    require "pdf-reader"
    require "timeout"
  end

  def parse_attached_file
    raise "No receipt file attached" unless file&.attached?

    begin
      file.blob.open do |pdf_file|
        reader = PDF::Reader.new(pdf_file)
        raise "PDF has no pages" if reader.page_count == 0

        pages_to_process = [ reader.page_count, 3 ].min
        text_content = reader.pages.first(pages_to_process).map.with_index do |page, index|
          page.text
        end.join("\n")

        text_content
      end
    rescue => e
      Rails.logger.error "Failed to extract text from receipt: #{e.class} - #{e.message}"
      raise "Failed to extract text from receipt: #{e.message}"
    end
  end
end
