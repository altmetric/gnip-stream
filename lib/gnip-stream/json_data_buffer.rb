require 'gnip-stream/json_extractor'

module GnipStream
  class JsonDataBuffer
    attr_accessor :buffer

    def initialize
      @buffer = ''
    end

    def process(chunk)
      @buffer.concat(chunk)
    end

    def complete_entries
      parser = JsonExtractor.new(@buffer)
      parser.process

      @buffer = parser.suffix
      parser.matches
    end
  end
end
