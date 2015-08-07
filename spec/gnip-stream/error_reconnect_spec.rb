require 'spec_helper'
require 'gnip-stream/error_reconnect'

require 'spec_helper'

describe GnipStream::ErrorReconnect do
  let(:fake_stream) { double('fake stream that causes errors') }
  subject { GnipStream::ErrorReconnect.new(fake_stream, :connect) }
  before { allow(subject).to receive(:sleep) }
  describe '#attempt_to_reconnect' do
    it 'should call the specified method on the class generating the error if reconnect count is less than 5' do
      expect(fake_stream).to receive(:connect)
      subject.attempt_to_reconnect('failed to reconnect')
    end

    it 'should raise an error with the specified error_message if reconnect fails maximum number of times' do
      subject.instance_variable_set(:@reconnect_attempts, 6)
      expect { subject.attempt_to_reconnect('failed to reconnect') }.to raise_error(/reconnect/)
    end
  end
end
