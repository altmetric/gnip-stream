require 'spec_helper'

require 'gnip-stream/stream'

describe GnipStream::Stream do
  let(:fake_processor) {
    double('json processor', process: self,
                             complete_entries: ['hello'])
  }
  subject { GnipStream::Stream.new('http://example.com', fake_processor) }

  describe '#initialize' do
    it 'allows you to define custom headers' do
      headers = { 'keep-alive' => false }
      stream = GnipStream::Stream.new('http://example.com', fake_processor, headers)
      expect(stream.headers).to eq(headers)
    end
  end

  describe '#on_message' do
    let(:on_message_block) { proc { puts 'hello world' } }
    it 'accepts a block that will be called every time a message is received' do
      subject.on_message(&on_message_block)
      expect(subject.instance_variable_get(:@on_message)).to eq(on_message_block)
    end
  end

  describe '#on_connection_close' do
    let(:on_connection_close_block) { proc { puts 'hello world' } }
    it 'accepts a block that will be called every time a message is received' do
      subject.on_connection_close(&on_connection_close_block)
      expect(subject.instance_variable_get(:@on_connection_close)).to eq(on_connection_close_block)
    end
  end

  describe '#on_error' do
    let(:on_error_block) { proc { puts 'hello world' } }
    it 'accepts a block that will be called every time a message is received' do
      subject.on_error(&on_error_block)
      expect(subject.instance_variable_get(:@on_error)).to eq(on_error_block)
    end
  end

  describe '#process_chunk' do
    let(:on_message_block) { proc { |message| message.to_s } }
    before do
      subject.on_message(&on_message_block)
      allow(EM).to receive(:defer)
    end
    it 'passes the chunk of data off to the processor object for processing' do
      expect(fake_processor).to receive(:process).with('hello world')
      subject.process_chunk('hello world')
    end

    it 'calls the client supplied callback on a seperate thread for each message' do
      expect(EventMachine).to receive(:defer)
      subject.process_chunk('hello')
    end
  end
end
