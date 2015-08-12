module GnipStream
  class JsonExtractor
    attr_reader :input, :matches, :suffix

    def initialize(input)
      @input = input
      @matches = []
      @suffix = input
    end

    def process
      start_pos = 0
      push_state :empty
      input.each_char.with_index do |c, pos|
        case current_state
        when :empty
          if c == '{'
            start_pos = pos
            push_state :in_brace
          end
        when :escaped
          pop_state
        when :quoted
          case c
          when '\\'
            push_state :escaped
          when '"'
            pop_state
          end
        else
          case c
          when '"'
            push_state :quoted
          when '{'
            push_state :in_brace
          when '}'
            pop_state
            if current_state == :empty
              @matches << input[start_pos..pos]
              @suffix = input[(pos + 1)..-1]
            end
          end
        end
      end
    end

    def push_state(state)
      states << state
    end

    def current_state
      states.last
    end

    def pop_state
      states.pop
    end

    def states
      @states ||= []
    end
  end
end
