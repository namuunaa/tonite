module AlexaUtteranceHelper

  def random_help_utterance
    sample_utterances = [
      "Alexa, ask Wing It for something to do",
      "Alexa, ask Wing It what is going on tonight",
      "Alexa, I want to do something with Wing It",
      "Alexa, Wing It",
      "Alexa, run Wing It",
      "Alexa, let's Wing It.",
      "Alexa, I want to Wing It",
      "Alexa, Wing It with me"
    ]
    sample_utterances.sample
  end

  # builds response & speech for when user asks for help
  def ask_help
    response = AlexaRubykit::Response.new
    response.add_speech("Try asking: #{random_help_utterance}")
    response.build_response
  end

end