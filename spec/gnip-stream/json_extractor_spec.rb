require 'spec_helper'
require 'gnip-stream/json_extractor'

RSpec.describe GnipStream::JsonExtractor do
  it 'locates a valid JSON packet within a string' do
    input = 'foo { "a": "b" } bar'

    parser = described_class.new(input)
    parser.process

    expect(parser.matches).to contain_exactly('{ "a": "b" }')
  end

  it 'identifies the text after the valid JSON packet' do
    input = 'foo { "a": "b" } bar'

    parser = described_class.new(input)
    parser.process

    expect(parser.suffix).to eq(' bar')
  end

  it 'allows for an opening brace within a string' do
    input = 'foo { "a": "b { c" } bar'

    parser = described_class.new(input)
    parser.process

    expect(parser.matches).to contain_exactly('{ "a": "b { c" }')
  end

  it 'allows for a closing brace within a string' do
    input = 'foo { "a": "b } c" } bar'

    parser = described_class.new(input)
    parser.process

    expect(parser.matches).to contain_exactly('{ "a": "b } c" }')
  end

  it 'can parse multiple JSON packets from a single string' do
    input = 'foo { "a": "b } c" } bar { "d": [1, 2, 3], "e": null } baz'

    parser = described_class.new(input)
    parser.process

    expect(parser.matches).to contain_exactly(
      '{ "a": "b } c" }',
      '{ "d": [1, 2, 3], "e": null }'
    )
  end

  it 'sets the correct suffix when multiple JSON packets are found' do
    input = 'foo { "a": "b } c" } bar { "d": [1, 2, 3], "e": null } baz'

    parser = described_class.new(input)
    parser.process

    expect(parser.suffix).to eq(' baz')
  end

  it 'does not grab an interior hash if the JSON is not complete' do
    input = '{"tweet": {"id": 1234567890123, body: "This tweet is not complete"}, "details": '

    parser = described_class.new(input)
    parser.process

    expect(parser.matches).to be_empty
  end

  it 'treats the whole string as the suffix if no complete JSON is found' do
    input = '{"tweet": {"id": 1234567890123'

    parser = described_class.new(input)
    parser.process

    expect(parser.suffix).to eq(input)
  end
end
