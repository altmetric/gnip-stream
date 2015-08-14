require 'eventmachine'
require 'em-http-request'

module GnipStream
  class Stream
    EventMachine.threadpool_size = 3

    attr_accessor :headers, :options, :url, :username, :password
    attr_reader :processor
    private :processor

    def initialize(url, processor: DataBuffer.new, headers: {})
      @url = url
      @headers = headers
      @processor = processor
    end

    def on_message(&block)
      @on_message = block
    end

    def on_connection_close(&block)
      @on_connection_close = block
    end

    def on_error(&block)
      @on_error = block
    end

    def connect
      EM.run do
        http = EM::HttpRequest.new(@url, inactivity_timeout: 45, connection_timeout: 75).get(head: headers)

        http.stream do |chunk|
          process_chunk(chunk)
        end

        http.callback do
          handle_connection_close(http)
          EM.stop
        end

        http.errback do
          handle_error(http)
          EM.stop
        end
      end
    end

    def process_chunk(chunk)
      processor.process(chunk)
      processor.complete_entries.each do |entry|
        EM.defer { @on_message.call(entry) }
      end
    end

    def handle_error(http_connection)
      @on_error.call(http_connection)
    end

    def handle_connection_close(http_connection)
      @on_connection_close.call(http_connection)
    end
  end
end
