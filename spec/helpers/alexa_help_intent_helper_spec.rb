require "spec_helper"

describe AlexaHelpIntentHelper do
  describe '#random_help_utterance' do
      let(:sample_utterances) do
      [
        "Alexa, ask Wing It for something to do",
        "Alexa, ask Wing It what is going on tonight",
        "Alexa, I want to do something with Wing It",
        "Alexa, Wing It",
        "Alexa, run Wing It",
        "Alexa, let's Wing It.",
        "Alexa, I want to Wing It",
        "Alexa, Wing It with me"
      ]
      end
    it 'includes a sample utterance' do
      expect(sample_utterances).to include(random_help_utterance)
    end
  end

  describe "#general_help_response" do
    it "returns with a suggestion of utterance to help with using the skill" do
      expect(JSON.parse(general_help_response)['response']['outputSpeech']['text']).to match(/Alexa, .*Wing It.*/)
    end
  end

  describe "#category_help_speech" do
    let(:response) do
      AlexaRubykit::Response.new
    end
    it "returns with a suggestion of categories to help with using the skill" do
      expect(category_help_speech(response)[:text]).to match("Here are some popular categories you can search: Food, Music, Sports, Nightlife, Meetups. Please refer to the card for the full list.")
    end
  end

  describe "#category_help_card" do
    let(:response) do
      AlexaRubykit::Response.new
    end
    let(:lookup_hash) do
      {'concerts' => 'music',
      'tour dates' => 'music',
      'conferences' => 'conference',
      'tradeshows' => 'conference'}
    end

    it 'returns a formatted string of all categories for the card' do
      expect(category_help_card(response, lookup_hash)[:content]).to match("Concerts\nTour dates\nConferences\nTradeshows\n")
    end
  end

  describe '#city_help_response' do
    let(:user) {User.create(user_id: "user_id", city: "My City")}
    it 'responds with a formatted card with the users city if they have set it' do
      expect(JSON.parse(city_help_response(user.user_id))['response']['outputSpeech']['text']).to eq('You are currently in the city of My City')
    end

    it 'responds with a message telling them the default city if they have not set it' do
      expect(JSON.parse(city_help_response('jibberish'))['response']['outputSpeech']['text']).to eq('You have not set your city yet. The default city is San Francisco')
    end
  end

end
