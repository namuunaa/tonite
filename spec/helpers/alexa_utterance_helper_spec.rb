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

  describe "#ask_help" do
    it "returns with a suggestion of utterance to help with using the skill" do 
        expect(JSON.parse(ask_help)['response']['outputSpeech']['text']).to match(/Alexa, .*Wing It.*/)
    end
  end
end