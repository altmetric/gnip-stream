require 'spec_helper'
require 'gnip-stream/json_data_buffer'

describe GnipStream::JsonDataBuffer do
  describe '#process' do
    it 'appends the data to an internal buffer' do
      json_buffer = GnipStream::JsonDataBuffer.new
      json_buffer.process('foo')
      json_buffer.process('bar')

      expect(json_buffer.buffer).to eq('foobar')
    end
  end

  describe '#complete_entries' do
    it 'correctly parses out each message into a separate entry' do
      json_buffer = GnipStream::JsonDataBuffer.new

      json_buffer.process('{"message": "a", "status": {"ok": true}}{"message": "b", "options": [true, false]}')
      json_buffer.process("\r\n{\"message\": \"partial\"")

      expect(json_buffer.complete_entries).to eq(['{"message": "a", "status": {"ok": true}}', '{"message": "b", "options": [true, false]}'])
    end

    it 'does not include blank lines' do
      json_buffer = GnipStream::JsonDataBuffer.new

      input_stream = '{"message": "a", "status": {"ok": true}}'
      input_stream += "\r\n\r\n"
      input_stream += '{"message": "b", "options": [true, false]}'
      input_stream += "\r\n{\"message\": \"partial\""

      json_buffer.process(input_stream)
      expect(json_buffer.complete_entries).to eq(['{"message": "a", "status": {"ok": true}}', '{"message": "b", "options": [true, false]}'])
    end
  end
end
