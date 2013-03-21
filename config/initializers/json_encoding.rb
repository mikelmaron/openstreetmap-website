# Revert a commit (https://github.com/rails/rails/commit/815a9431ab61376a7e8e1bdff21f87bc557992f8)
# that introduced encoding problems. See https://github.com/rails/rails/issues/9498
module ActiveSupport
  module JSON
    module Encoding
      def self.escape(string)
        if string.respond_to?(:force_encoding)
          string = string.encode(::Encoding::UTF_8, :undef => :replace).force_encoding(::Encoding::BINARY)
        end
        json = string.
          gsub(escape_regex) { |s| ESCAPED_CHARS[s] }.
          gsub(/([\xC0-\xDF][\x80-\xBF]|
                 [\xE0-\xEF][\x80-\xBF]{2}|
                 [\xF0-\xF7][\x80-\xBF]{3})+/nx) { |s|
          s.unpack("U*").pack("n*").unpack("H*")[0].gsub(/.{4}/n, '\\\\u\&')
        }
        json = %("#{json}")
        json.force_encoding(::Encoding::UTF_8) if json.respond_to?(:force_encoding)
        json
      end
    end
  end
end
