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
    let(:api_response) do
      select_not_started(helper.call)
    end

    let(:all_day_test_events) do
      events = [
      {'title' => 'All Day 0 Event', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 19:00', 'olson_path' => 'America/Los_Angeles', 'all_day' => "0"},
      {'title' => 'All Day 1 Event', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 00:00', 'olson_path' => 'America/Los_Angeles', 'all_day' => "1"},
      {'title' => 'All Day 2 Event', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 00:00', 'olson_path' => 'America/Los_Angeles', 'all_day' => "2"}
      ]
    end


    it 'only selects events whose start time is after the current time' do
      Time.zone = 'America/Los_Angeles'

      api_response.each do |event|
        event_start = Time.parse(event["start_time"])
        event_not_started = (event_start > Time.zone.now || event['all_day'] != "0" )
        expect(event_not_started).to be true
      end
    end

    it 'selects all-day events if the current time is before 6 pm' do
      Time.zone = 'America/Los_Angeles'
      current_time = Time.parse("2017-04-29 17:59:00")

      allow(Time.zone).to receive(:now).and_return(current_time)

      expect(select_not_started(all_day_test_events).length).to eq 3
    end

    it 'does not select all-day events if the current time is 6pm or later' do
      Time.zone = 'America/Los_Angeles'
      current_time = Time.parse("2017-04-29 18:00:00")

      allow(Time.zone).to receive(:now).and_return(current_time)

      select_not_started(all_day_test_events).each do |event|
          not_all_day =  event['all_day'] == "0"
          expect(not_all_day).to be true
      end

      expect(select_not_started(all_day_test_events).length).to eq 1
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
      {'title' => 'Hamilton', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 18:00', 'olson_path' => 'America/Los_Angeles', 'all_day' => "0"}
    end

    it "does not include an @speech attribute before the add_speech method is run" do
      expect(response.speech).to be nil
    end

    it "adds an @speech attribute after the add_speech method is run" do
      format_speech_for_alexa(response, event)
      time = time_until(event)
      expect(response.speech[:text]).to be_a_kind_of(String)
      expect(response.speech[:text]).not_to be_empty
    end

    it "returns speech in the expected format for an all-day event" do
      event['all_day'] = "1"
      format_speech_for_alexa(response, event)
      time = time_until(event)
      expect(response.speech[:text]).to eq("Hamilton is happening at DBC. This is an all-day event.")
    end

    it "returns speech in the expected format for an event with a start time" do
      format_speech_for_alexa(response, event)
      time = time_until(event)
      expect(response.speech[:text]).to eq("Hamilton is happening at DBC#{time}")
    end
  end

  describe '#time_until' do
    let(:event1) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => Time.parse("2017-04-29 18:25:00").to_s, 'all_day' => "0"}
    end

    let(:start_time1) do
      start_time = DateTime.parse(event1['start_time']).strftime('%l:%M %p')
    end

    let(:event2) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => Time.parse("2017-04-29 19:01:00").to_s, 'all_day' => "0"}
    end

    let(:start_time2) do
      start_time = DateTime.parse(event2['start_time']).strftime('%l:%M %p')
    end

    let(:event3) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => Time.parse("2017-04-29 20:46:00").to_s, 'all_day' => "0"}
    end

    let(:start_time3) do
      start_time = DateTime.parse(event3['start_time']).strftime('%l:%M %p')
    end

    let(:event4) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => Time.parse("2017-04-29 17:46:00").to_s, 'all_day' => "0"}
    end

    let(:start_time4) do
      start_time = DateTime.parse(event4['start_time']).strftime('%l:%M %p')
    end

    let(:event5) do
      {'olson_path' => 'America/Los_Angeles', 'start_time' => Time.parse("2017-04-29 20:00:00").to_s, 'all_day' => "0"}
    end

    let(:start_time5) do
      start_time = DateTime.parse(event5['start_time']).strftime('%l:%M %p')
    end

    let(:event6) do
      {'olson_path' => 'America/Los_Angeles', 'all_day' => "1"}
    end

    let(:event7) do
      {'olson_path' => 'America/Los_Angeles','all_day' => "2"}
    end

    it 'displays time left till the event' do
      current_time = Time.parse("2017-04-29 17:00:00")
      allow(Time.zone).to receive(:now).and_return(current_time)
      expect(time_until(event1)).to eq(" starting at #{start_time1}. You have 1 hr and 25 min to get ready.")
      expect(time_until(event2)).to eq(" starting at #{start_time2}. You have 2 hr and 1 min to get ready.")
      expect(time_until(event3)).to eq(" starting at #{start_time3}. You have 3 hr and 46 min to get ready.")
      expect(time_until(event4)).to eq(" starting at #{start_time4}. You have 46 min to get ready.")
      expect(time_until(event5)).to eq(" starting at #{start_time5}. You have 3 hr to get ready.")
    end

    it 'informs the user of an all-day event without displaying the start time and time to get ready' do
      current_time = Time.parse("2017-04-29 17:00:00")
      allow(Time.zone).to receive(:now).and_return(current_time)
      expect(time_until(event6)).to eq(". This is an all-day event.")
      expect(time_until(event7)).to eq(". This is an all-day event.")
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
      { 'title' => 'Hamilton', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 18:00', 'all_day' => "0", 'url' => 'http://www.hamiltonevent.com' }
    end

    it 'formats a string with the event details' do
      expect(generate_single_event_text_for_card(event)).to eq("Event: Hamilton \n Venue: DBC \n Time:  6:00 PM \n Description: We don\'t have any details on this event \n More Info: http://www.hamiltonevent.com")
    end

    it 'displays the time as "All day" for all-day events' do
      event['all_day'] = "1"

      expect(generate_single_event_text_for_card(event)).to eq("Event: Hamilton \n Venue: DBC \n Time: All day \n Description: We don\'t have any details on this event \n More Info: http://www.hamiltonevent.com")
    end
  end

  # describe '#format_text_for_alexa'

  describe '#get_location' do
    it 'will return location: "San Francisco" if there is no user with the appropriate id' do
      controller.params['session'] = {'user' => {'userId' => 'my_id'}}
      expect(get_location).to eq({location: 'San Francisco'})
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
