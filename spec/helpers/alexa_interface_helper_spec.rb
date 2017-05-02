require "spec_helper"

describe AlexaInterfaceHelper do
  describe "#call" do
    it "returns an array of hashes" do
      response = helper.call({})
      expect(response).to be_a_kind_of(Array)
      expect(response[0]).to be_a_kind_of(Hash)
    end

    it "returns events that are occurring today" do
      response = helper.call({})
      # Check "start_time" for each event in the array
        # Convert from string to Datetime obj
        # compare date part with Datetime.today
      response.each do |event|
        event_start = DateTime.parse(event["start_time"])
        expect(event_start.strftime("%F")).to eq(Date.today.strftime("%F"))
      end
    end
  end

  describe '#select_not_started' do
    let(:response) do
      select_not_started(helper.call)
    end

    it 'only selects events whose start time is after the current time' do
      response.each do |event|
        event_start = Time.parse(event["start_time"])
        event_not_started = (event_start > Time.now || event['all_day'] != 0 )
        expect(event_not_started).to be true
      end
    end


  end

  describe '#pick10' do
    let(:response) do
      helper.call
    end

    it 'outputs an array with a length of 10' do
      expect(pick10(response).length).not_to be > 10
    end

    it 'outputs an array even if input array contains less than 10 events' do
      expect(pick10(response[0..3]).length).to be 4
    end
  end

  describe '#pick1' do
    let(:response) do
      pick10(helper.call)
    end

    it 'outputs a hash' do
      expect(pick1(response)).to be_a_kind_of(Hash)
    end

    it 'outputs nil if it takes an empty array' do
      expect(pick1([])).to be nil
    end
  end

  describe '#format_speech_for_alexa' do
    let(:response) do
      AlexaRubykit::Response.new
    end

    let(:event) do
      {'title' => 'Hamilton', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 18:00', 'olson_path' => 'America/Los_Angeles'}
    end

    it "does not include an @speech attribute before the add_speech method is run" do
      expect(response.speech).to be nil
    end

    it "adds an @speech attribute after the add_speech method is run" do
      format_speech_for_alexa(response, event)
      time = time_until(event)
      expect(response.speech[:text]).to eq("Hamilton is happening at DBC starting at  6:00 PM. You have #{time} to get ready.")
    end
  end

  describe '#time_until' do
    let(:event1) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => (DateTime.now + 1.hour + 25.minutes).to_s}
    end
    let(:event2) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => (DateTime.now + 2.hour + 1.minutes).to_s}
    end
    let(:event3) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => (DateTime.now + 3.hour + 46.minutes).to_s}
    end
    let(:event4) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => (DateTime.now + 0.hour + 46.minutes).to_s}
    end
    let(:event5) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => (DateTime.now + 3.hour + 0.minutes).to_s}
    end

    it 'displays time left till the event' do
      expect(time_until(event1)).to eq("1 hour and 25 minutes")
      expect(time_until(event2)).to eq("2 hours and 1 minute")
      expect(time_until(event3)).to eq("3 hours and 46 minutes")
      expect(time_until(event4)).to eq("46 minutes")
      expect(time_until(event5)).to eq("3 hours")
    end

  end

  describe '#format_html_text_to_string' do
    describe '#format_html' do
      let(:html_text) do
        "<br>Souvenir is his band&#39;s most expansive album to date, dishing up everything from the West Coast<br>country-rock of &quot;California&quot; to the front-porch folk of &quot;Mama Sunshine, Daddy&#39;s Rain.&quot;"
      end

      it 'removes html tags and formats into alexa writable string' do
        alexa_text = format_html_text_to_string(html_text)
        expect(alexa_text).to eq("\nSouvenir is his band's most expansive album to date, dishing up everything from the West Coast\ncountry-rock of \"California\" to the front-porch folk of \"Mama Sunshine, Daddy's Rain.\"")
      end
    end

    describe '#clip' do
      it 'clips descriptions longer than 500 characters down to 500 + ...' do
        desc = "a" * 600
        expect(clip(desc).length).to eq(503)
        expect(clip(desc)[(-3..-1)]).to eq("...")
      end
    end
  end

  describe '#find_formatted_description' do
    it 'returns default description if the event has no description' do
      event_hash = {}
      expect(find_formatted_description(event_hash)).to eq('We don\'t have any details on this event')
    end

    it 'formats the string correctly if there is a description' do
      event_hash = {'description' => "<br>Souvenir is his band&#39;s most expansive album to date, dishing up everything from the West Coast<br>country-rock of &quot;California&quot; to the front-porch folk of &quot;Mama Sunshine, Daddy&#39;s Rain.&quot;"}
      expect(find_formatted_description(event_hash)).to eq("\nSouvenir is his band's most expansive album to date, dishing up everything from the West Coast\ncountry-rock of \"California\" to the front-porch folk of \"Mama Sunshine, Daddy's Rain.\"")
    end
  end

  describe '#generate_single_event_text_for_card' do
    let(:event) do
      { 'title' => 'Hamilton', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 18:00', 'url' => 'http://www.hamiltonevent.com' }
    end

    it 'formats a string with the event details' do
      expect(generate_single_event_text_for_card(event)).to eq("Event: Hamilton \n Venue: DBC \n Time:  6:00 PM \n Description: We don\'t have any details on this event \n More Info: http://www.hamiltonevent.com")
    end
  end

  # describe '#format_text_for_alexa'

  describe '#get_location' do
    it 'will return an empty hash if there is no user with the appropriate id' do
      controller.params['session'] = {'user' => {'userId' => 'my_id'}}
      expect(get_location).to eq({})
    end

    it 'will return a hash with location: "city" if there is such a user in the db' do
      User.create(user_id: 'my_id', city: 'my_city')
      controller.params['session'] = {'user' => {'userId' => 'my_id'}}
      expect(get_location).to eq({location: 'my_city'})
    end
  end

  describe '#get_user_id' do
    it 'takes a user_id out of params' do
      controller.params['session'] = {'user' => {'userId' => 'my_id'}}
      expect(get_user_id).to eq('my_id')
    end
  end

  describe '#get_city_from_json' do
    it 'takes a city out of params' do
      controller.params['request'] = {'intent' => {'slots' => {'city' => {'value' => 'my_city'}}}}
      expect(get_city_from_json).to eq('my_city')
    end
  end
end
