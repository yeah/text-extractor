# frozen_string_literal: true

module TextExtractor
  class Resolver
    MAX_FULLTEXT_LENGTH = 4194304 # 4 megabytes

    def initialize(file, content_type = nil)
      @file = file
      @content_type = content_type
    end

    # returns the extracted fulltext or nil if no matching handler was found
    # for the file type.
    def text
      if handler = find_handler and text = handler.text(@file)
        text.gsub! /\s+/m, ' '
        text.strip!
        text.mb_chars.compose.limit(MAX_FULLTEXT_LENGTH).to_s
      end
    end

    private

    def find_handler
      @@file_handlers.detect{|h| h.accept? @content_type }
    end

    # the handler chain. List most specific handlers first and more general
    # (fallback) handlers later.
    @@file_handlers = [
        TextExtractor::PdfHandler,
        TextExtractor::OpendocumentHandler,
        TextExtractor::DocxHandler, TextExtractor::XlsxHandler, TextExtractor::PptxHandler,
        TextExtractor::DocHandler, TextExtractor::XlsHandler, TextExtractor::PptHandler,
        TextExtractor::ImageHandler,
        TextExtractor::RtfHandler,
        TextExtractor::PlaintextHandler
    ].map(&:new)
  end
end
