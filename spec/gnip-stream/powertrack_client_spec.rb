require 'spec_helper'
require 'gnip-stream/powertrack_client'

describe GnipStream::PowertrackClient do
  let(:fake_stream) { double('GnipStream::JsonStream').as_null_object }
  before do
    allow(GnipStream::JsonStream).to receive(:new).and_return(fake_stream)
  end

  subject { GnipStream::PowertrackClient.new('http://example.com', 'user', 'password') }

  describe '#initialize' do
    it 'initializes an instance JsonStream' do
      expect(GnipStream::JsonStream).to receive(:new)
      subject
    end
  end

  describe 'configure_handlers' do
    it 'sets up the appropriate error and close handlers' do
      expect(fake_stream).to receive(:on_error).twice
      expect(fake_stream).to receive(:on_connection_close).twice
      subject.configure_handlers
    end
  end

  describe '#consume' do
    it 'setup the client callback' do
      expect(fake_stream).to receive(:on_message)
      subject.consume
    end

    it 'connects to the stream' do
      expect(fake_stream).to receive(:connect)
      subject.consume
    end
  end
end
