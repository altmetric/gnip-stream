require 'spec_helper'
require 'gnip-stream/facebook_client'
require 'gnip-stream/error_reconnect'

describe GnipStream::FacebookClient do
  let(:fake_stream) { double('GnipStream::XmlStream').as_null_object }
  before { allow(GnipStream::XmlStream).to receive(:new).and_return(fake_stream) }
  let(:client) { GnipStream::FacebookClient.new('http://example.com', 'user', 'password') }

  describe '#consume' do
    it 'setup the client callback' do
      expect(fake_stream).to receive(:on_message)
      client.consume
    end

    it 'connects to the stream' do
      expect(fake_stream).to receive(:connect)
      client.consume
    end
  end

  describe 'configure_handlers' do
    it 'sets up the appropriate error and close handlers' do
      expect(fake_stream).to receive(:on_error).twice
      expect(fake_stream).to receive(:on_connection_close).twice
      client.configure_handlers
    end
  end
end
