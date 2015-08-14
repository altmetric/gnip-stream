require 'gnip-stream/data_buffer'
require 'gnip-stream/error_reconnect'

module GnipStream
  class PowertrackClient
    def initialize(url:, username:, password:)
      @stream = Stream.new(
        url,
        processor: DataBuffer.new,
        headers: { 'authorization' => [username, password], 'accept-encoding' => 'gzip, compressed' }
      )
      @error_handler = ErrorReconnect.new(self, :consume)
      @connection_close_handler = ErrorReconnect.new(self, :consume)
      configure_handlers
    end

    def configure_handlers
      @stream.on_error do |error|
        @error_handler.attempt_to_reconnect("Gnip Connection Error. Reason was: #{error.inspect}")
      end

      @stream.on_connection_close do
        @connection_close_handler.attempt_to_reconnect('Gnip Connection Closed')
      end
    end

    def consume(&block)
      @client_callback = block if block
      @stream.on_message(&@client_callback)
      @stream.connect
    end
  end
end
