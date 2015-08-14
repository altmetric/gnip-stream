require 'spec_helper'
require 'gnip-stream/data_buffer'

describe GnipStream::DataBuffer do
  describe '#process' do
    it 'appends the data to an internal buffer' do
      json_buffer = described_class.new
      json_buffer.process('foo')
      json_buffer.process('bar')

      expect(json_buffer.buffer).to eq('foobar')
    end

    it 'throws an error if the buffer fills beyond capacity' do
      json_buffer = described_class.new(maximum_size: 102)
      10.times { json_buffer.process('1234567890') }

      expect { json_buffer.process('1234567890') }.to raise_error(GnipStream::BufferFullError)
    end
  end

  describe '#complete_entries' do
    it 'correctly parses out each message into a separate entry' do
      json_buffer = described_class.new

      json_buffer.process('{"message": "a", "status": {"ok": true}}{"message": "b", "options": [true, false]}')
      json_buffer.process("\r\n{\"message\": \"partial\"")

      expect(json_buffer.complete_entries).to eq(['{"message": "a", "status": {"ok": true}}', '{"message": "b", "options": [true, false]}'])
    end

    it 'does not include blank lines' do
      json_buffer = described_class.new

      input_stream = '{"message": "a", "status": {"ok": true}}'
      input_stream += "\r\n\r\n"
      input_stream += '{"message": "b", "options": [true, false]}'
      input_stream += "\r\n{\"message\": \"partial\""

      json_buffer.process(input_stream)
      expect(json_buffer.complete_entries).to eq(['{"message": "a", "status": {"ok": true}}', '{"message": "b", "options": [true, false]}'])
    end
  end

  context 'when a large tweet is sent over in chunks' do
    it 'correctly parses the whole JSON' do
      incoming_json = <<-EOJSON
      {"id":"tag:search.twitter.com,2005:630768185558630400","objectType":"activity","actor":{"objectType":"person","id":"id:twitter.com:27834920","link":"http://www.twitter.com/GrrlScientist","displayName":"GrrlScientist","postedTime":"2009-03-31T07:56:11.000Z","image":"https://pbs.twimg.com/profile_images/507869943094722561/f5lNC_KV_normal.jpeg","summary":"Evolutionary biologist, ornithologist, birder, parrot pal, writes for the @Guardian & @BirdNoteRadio, veg*n, progressive Seattlebred NYCer, US expat, Ravenclaw.","links":[{"href":"http://www.theguardian.com/science/grrlscientist","rel":"me"}],"friendsCount":526,"followersCount":19212,"listedCount":1391,"statusesCount":4932,"twitterTimeZone":"London","verified":false,"utcOffset":"3600","preferredUsername":"GrrlScientist","languages":["en"],"location":{"objectType":"place","displayName":"40.7619, -73.9763"},"favoritesCount":45},"verb":"post","postedTime":"2015-08-10T15:50:29.000Z","generator":{"displayName":"Twitter Web Client","link":"http://twitter.com"},"provider":{"objectType":"service","displayName":"Twitter","link":"http://www.twitter.com"},"link":"http://twitter.com/GrrlScientist/statuses/630768185558630400","body":"Slideshow: Glowing predators of the deep http://t.co/prpAtsvstd #marinelife #photography http://t.co/vl3bYeci8C","object":{"objectType":"note","id":"object:search.twitter.com,2005:630768185558630400","summary":"Slideshow: Glowing predators of the deep http://t.co/prpAtsvstd #marinelife #photography http://t.co/vl3bYeci8C","link":"http://twitter.com/GrrlScientist/statuses/630768185558630400","postedTime":"2015-08-10T15:50:29.000Z"},"favoritesCount":0,"twitter_entities":{"hashtags":[{"text":"marinelife","indices":[64,75]},{"text":"photography","indices":[76,88]}],"trends":[],"urls":[{"url":"http://t.co/prpAtsvstd","expanded_url":"http://bit.ly/1N3Xdik","display_url":"bit.ly/1N3Xdik","indices":[41,63]}],"user_mentions":[],"symbols":[],"media":[{"id":630768184698736640,"id_str":"630768184698736640","indices":[89,111],"media_url":"http://pbs.twimg.com/media/CMDwUnCWEAAqnpc.jpg","media_url_https":"https://pbs.twimg.com/media/CMDwUnCWEAAqnpc.jpg","url":"http://t.co/vl3bYeci8C","display_url":"pic.twitter.com/vl3bYeci8C","expanded_url":"http://twitter.com/GrrlScientist/status/630768185558630400/photo/1","type":"photo","sizes":{"thumb":{"w":150,"h":150,"resize":"crop"},"small":{"w":340,"h":191,"resize":"fit"},"medium":{"w":600,"h":337,"resize":"fit"},"large":{"w":1024,"h":576,"resize":"fit"}}}]},"twitter_extended_entities":{"media":[{"id":630768184698736640,"id_str":"630768184698736640","indices":[89,111],"media_url":"http://pbs.twimg.com/media/CMDwUnCWEAAqnpc.jpg","media_url_https":"https://pbs.twimg.com/media/CMDwUnCWEAAqnpc.jpg","url":"http://t.co/vl3bYeci8C","display_url":"pic.twitter.com/vl3bYeci8C","expanded_url":"http://twitter.com/GrrlScientist/status/630768185558630400/photo/1","type":"photo","sizes":{"thumb":{"w":150,"h":150,"resize":"crop"},"small":{"w":340,"h":191,"resize":"fit"},"medium":{"w":600,"h":337,"resize":"fit"},"large":{"w":1024,"h":576,"resize":"fit"}}}]},"twitter_filter_level":"low","twitter_lang":"en","retweetCount":0,"gnip":{"matching_rules":[{"value":"url_contains:\"sciencemag.org\"","tag":"sciencemag.org"}],"urls":[{"url":"http://t.co/vl3bYeci8C","expanded_url":"http://twitter.com/GrrlScientist/status/630768185558630400/photo/1","expanded_status":200},{"url":"http://t.co/prpAtsvstd","expanded_url":"http://news.sciencemag.org/biology/2015/08/slideshow-glowing-predators-deep?utm_campaign=email-news-latest&utm_src=email","expanded_status":200}],"klout_score":67,"language":{"value":"en"}}}
      EOJSON
      incoming_chunks = incoming_json.scan(/.{,200}/)

      json_buffer = described_class.new

      outputs = []
      incoming_chunks.each do |chunk|
        json_buffer.process(chunk)
        outputs += json_buffer.complete_entries
      end

      expect(outputs.size).to eq(1)
    end
  end

  context 'when a JSON packet includes unmatched braces in text' do
    context 'and that umatched brace is an opening brace' do
      it 'includes all JSON objects in its output' do
        json_stream = '{"text": "Body with a { in it"}{"text": "Body with no braces"}'
        json_buffer = described_class.new

        json_buffer.process(json_stream)

        expect(json_buffer.complete_entries).to contain_exactly(
          '{"text": "Body with a { in it"}',
          '{"text": "Body with no braces"}'
        )
      end
    end

    context 'and that umatched brace is a closing brace' do
      it 'includes all JSON objects in its output' do
        json_stream = '{"text": "Body with a } in it"}{"text": "Body with no braces"}'
        json_buffer = described_class.new

        json_buffer.process(json_stream)

        expect(json_buffer.complete_entries).to contain_exactly(
          '{"text": "Body with a } in it"}',
          '{"text": "Body with no braces"}'
        )
      end
    end
  end

  context 'when a JSON packet includes a string with an escaped quotation mark' do
    it 'includes all JSON objects in its output' do
      json_stream = '{"text": "Body with a \" in it"}{"text": "Body with no braces"}'
      json_buffer = described_class.new

      json_buffer.process(json_stream)

      expect(json_buffer.complete_entries).to contain_exactly(
        '{"text": "Body with a \" in it"}',
        '{"text": "Body with no braces"}'
      )
    end
  end
end
