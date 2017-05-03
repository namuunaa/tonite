require "spec_helper"

describe AlexaUtteranceHelper do
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
    it "returns with a suggestion of categories to help with using the skill" do 
      expect(JSON.parse(category_help_response)['response']['outputSpeech']['text']).to match("Here are some popular categories you can search: Food, Music, Sports, Nightlife, Meetups. Please refer to the card for the full list.")
    end
  end
end