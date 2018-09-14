require 'gnip-stream/errors'
require 'gnip-stream/json_extractor'

module GnipStream
  class JsonDataBuffer
    attr_accessor :buffer
    attr_reader :maximum_size
    private :maximum_size

    def initialize(maximum_size: 1_000_000)
      @buffer = ''
      @maximum_size = maximum_size
    end

    def process(chunk)
      buffer.concat(chunk)

      fail GnipStream::BufferFullError, "Buffer is: #{buffer}" if buffer.size > maximum_size
    end

    def complete_entries
      parser = JsonExtractor.new(@buffer)
      parser.process

      self.buffer = parser.suffix
      parser.matches
    end
  end
end
