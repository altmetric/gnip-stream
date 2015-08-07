require 'spec_helper'
require 'gnip-stream/xml_data_buffer'

describe GnipStream::XmlDataBuffer do
  subject { GnipStream::XmlDataBuffer.new(/(test)(.*)/) }
  describe '#initialize' do
    it 'accepts a regex pattern that will be used to match complete entries' do
      pattern = Regexp.new(/hello/)
      expect(GnipStream::XmlDataBuffer.new(pattern).pattern).to eq(pattern)
    end
  end

  describe '#process' do
    it 'appends the data to the buffer' do
      subject.process('hello')
      expect(subject.instance_variable_get(:@buffer)).to eq('hello')
    end
  end

  describe '#complete_entries' do
    it 'returns a list of complete entries' do
      subject.process('test')
      expect(subject.complete_entries).to eq(['test'])
    end
  end
end
