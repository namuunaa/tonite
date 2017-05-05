require "spec_helper"

describe AlexaEastereggHelper do
  describe "#get_easter_egg" do
    it 'returns a formatted string with the expected response' do
      allow(Time.zone).to receive(:now).and_return(Time.parse('2017-05-05 16:20:00'))

      easter_egg_response = JSON.parse(get_easter_egg)["response"]["outputSpeech"]["text"]

      expect(easter_egg_response).to match (/The Wild Pigs graduation party is happening at Sparks Social SF starting at  6:30 PM. You have (\d+ hr and \d+ min|\d+ hr|\d+ min) to get ready. Time to celebrate!/)
    end
  end
end