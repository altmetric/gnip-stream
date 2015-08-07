require 'spec_helper'
require 'gnip-stream/json_data_buffer'

describe GnipStream::JsonDataBuffer do
  let(:json_buffer) { GnipStream::JsonDataBuffer.new("\r\n", Regexp.new(/^.*\r\n/)) }
  describe '#initialize' do
    it 'accepts a regex pattern that will be used to match complete entries' do
      split_pattern = "\n"
      check_pattern = /hello\r\n/
      expect(GnipStream::JsonDataBuffer.new(split_pattern, check_pattern).check_pattern).to eq(check_pattern)
      expect(GnipStream::JsonDataBuffer.new(split_pattern, check_pattern).split_pattern).to eq(split_pattern)
    end
  end

  describe '#process' do
    it 'appends the data to the buffer' do
      json_buffer.process("hello\r\nother")
      expect(json_buffer.instance_variable_get(:@buffer)).to eq("hello\r\nother")
    end
  end

  describe '#complete_entries' do
    it 'returns a list of complete entries' do
      json_buffer.process("hello\r\nother")
      expect(json_buffer.complete_entries).to eq(['hello'])
      expect(json_buffer.instance_variable_get(:@buffer)).to eq('other')
    end
  end

  describe '#multiple complete_entries' do
    it 'returns a list of complete entries' do
      json_buffer.process("hello\r\nhello2\r\nhello3\r\nhel")
      expect(json_buffer.complete_entries).to eq(%w(hello hello2 hello3))
      expect(json_buffer.instance_variable_get(:@buffer)).to eq('hel')
    end
  end
end
