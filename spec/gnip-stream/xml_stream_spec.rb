require 'spec_helper'
require 'gnip-stream/xml_stream'

describe GnipStream::XmlStream do
  subject { GnipStream::XmlStream.new('http://example.com') }
  describe '#initialize' do
    it 'creates underlying stream object with a json specific data buffer' do
      expect(GnipStream::Stream).to receive(:new) do |url, _processor, _headers|
        expect(url).to eq('http://example.com')
      end
      GnipStream::XmlStream.new('http://example.com')
    end
  end

  describe '#method_missing' do
    let(:underlying_stream) { double('GnipStream::Stream') }
    before do
      allow(GnipStream::Stream).to receive(:new).and_return(underlying_stream)
    end

    it 'delegates all available methods to the underlying stream class' do
      expect(underlying_stream).to receive(:connect)
      subject.connect
    end

    it 'raises a method not found error on self if underlying stream can not respond to the method' do
      expect { subject.foobar }.to raise_error(NoMethodError)
    end
  end
end
