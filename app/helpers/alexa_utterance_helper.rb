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
  def general_help_response
    response = AlexaRubykit::Response.new
    response.add_speech("Try asking: #{random_help_utterance}")
    response.build_response
  end
  # builds response speech and card for list of categories when asked for help for categories
  def category_help_response
    response = AlexaRubykit::Response.new
    category_help_speech
    category_help_card
    response.build_response
  end

  def category_help_speech
    response.add_speech("Here are some popular categories you can search: Food, Music, Sports, Nightlife, Meetups. Please refer to the card for the full list.")
  end

  def category_help_card
    categories_card = @lookup_hash.keys.reduce('') {|card, category| card + category.capitalize + '\n'}
    response.add_card('Simple', 'Event Categories:', nil, categories_card)
  end

end