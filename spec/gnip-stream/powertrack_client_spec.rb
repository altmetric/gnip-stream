require 'spec_helper'
require 'gnip-stream/powertrack_client'
require 'gnip-stream/stream'
require 'gnip-stream/error_reconnect'

describe GnipStream::PowertrackClient do
  let(:fake_stream) { double('GnipStream::Stream').as_null_object }
  before do
    allow(GnipStream::Stream).to receive(:new).and_return(fake_stream)
  end

  describe '#initialize' do
    it 'initializes a stream' do
      expect(GnipStream::Stream).to receive(:new)
      build_client
    end
  end

  describe 'configure_handlers' do
    it 'sets up the appropriate error and close handlers' do
      expect(fake_stream).to receive(:on_error)
      expect(fake_stream).to receive(:on_connection_close)
      build_client
    end
  end

  describe '#consume' do
    it 'sets up the client callback' do
      client = build_client

      expect(fake_stream).to receive(:on_message)
      client.consume
    end

    it 'connects to the stream' do
      client = build_client

      expect(fake_stream).to receive(:connect)
      client.consume
    end
  end

  def build_client
    described_class.new(url: 'http://example.com', username: 'user', password: 'password')
  end
end
