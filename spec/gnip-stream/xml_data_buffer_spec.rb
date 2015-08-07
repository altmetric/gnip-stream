require 'spec_helper'
require 'gnip-stream/xml_data_buffer'

describe GnipStream::XmlDataBuffer do
  let(:buffer) { GnipStream::XmlDataBuffer.new(/(test)(.*)/) }
  describe '#initialize' do
    it 'accepts a regex pattern that will be used to match complete entries' do
      pattern = Regexp.new(/hello/)
      expect(GnipStream::XmlDataBuffer.new(pattern).pattern).to eq(pattern)
    end
  end

  describe '#process' do
    it 'appends the data to the buffer' do
      buffer.process('hello')
      expect(buffer.instance_variable_get(:@buffer)).to eq('hello')
    end
  end

  describe '#complete_entries' do
    it 'returns a list of complete entries' do
      buffer.process('test')
      expect(buffer.complete_entries).to eq(['test'])
    end
  end
end
