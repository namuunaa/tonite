require "spec_helper"

describe AlexaInterfaceHelper do
  describe "#call" do
    it "returns an array of hashes" do
      response = helper.call({})
      expect(response).to be_a_kind_of(Array)
      expect(response[0]).to be_a_kind_of(Hash)
    end

    xit "makes an API call" do
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
      {'title' => 'Hamilton', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 18:00'}
    end

    it "does not include an @speech attribute before the add_speech method is run" do
      expect(response.speech).to be nil
    end

    it "adds an @speech attribute after the add_speech method is run" do
      format_speech_for_alexa(response, event)
      expect(response.speech[:text]).to eq("Hamilton is happening at DBC starting at  6:00 PM")
    end

  end

end
