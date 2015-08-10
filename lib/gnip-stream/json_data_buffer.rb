module GnipStream
  class JsonDataBuffer
    JSON_BRACE_MATCHING = /\A\s*(?<match>\{(?:\g<match>|[^{}]++)*\})(?<excess>.*\z)/m
    attr_accessor :buffer

    def initialize
      @buffer = ''
    end

    def process(chunk)
      @buffer.concat(chunk)
    end

    def complete_entries
      entries = []
      while (look_for_json = @buffer.match(JSON_BRACE_MATCHING))
        entries << look_for_json[:match]
        @buffer = look_for_json[:excess]
      end

      entries
    end
  end
end
