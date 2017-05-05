module AlexaInterfaceHelper

  # uses everything and returns a full response object to send to alexa
  def create_response(call_parameters)
    response_for_alexa = AlexaRubykit::Response.new
    response = call(call_parameters)
    not_started = select_not_started(response)
    if not_started.length > 0
      top_ten = pick10(not_started)
      top_one = pick1(top_ten)
      format_results_speech_for_alexa(response_for_alexa, top_one)
      format_results_text_for_alexa(response_for_alexa, top_ten)
    else
      format_no_events_found_speech_for_alexa(response_for_alexa)
    end
    response_for_alexa.build_response
  end

  # this method and the one above could probably be re factored to be more similar or even joined into one method maybe? (search time is a concern...)
  def category_search_response(lookup_hash)
    given_category = params["request"]["intent"]["slots"]["category"]["value"].downcase
    category = lookup_hash[given_category]
    if category
      response_for_alexa = AlexaRubykit::Response.new
      response = category_call({location: get_location[:location], category: category})
      not_started = select_not_started(response)
      if not_started.length > 0
        top_ten = pick10(not_started)
        top_one = pick1(top_ten)
        format_results_category_speech_for_alexa(response_for_alexa, top_one, given_category)
        format_results_text_for_alexa(response_for_alexa, top_ten)
      else
        format_no_events_found_speech_for_alexa(response_for_alexa)
      end
      response_for_alexa.build_response
    else
      generate_bad_category_response(given_category)
    end
  end

  # make the eventful api call when a category is given
  def category_call(call_parameters = {})
    # page size is 10 for testing; should be ~50 for production
    if Rails.env.production?
      page_size = "50"
    else
      page_size = "10"
    end

    parameters_hash = {category: call_parameters[:category], location: call_parameters[:location], date: "Today", sort_order: "popularity", mature: "normal", page_size: page_size, change_multi_day_start: "true" }
    client = EventfulApi::Client.new({})
    response = client.get('/events/search', parameters_hash)
    # hash > "events" > "event" > array of events
    response["events"]["event"]
  end

  # generate response for alexa when the given category is invalid
  def generate_bad_category_response(category)
    response_for_alexa = AlexaRubykit::Response.new
    response_for_alexa.add_speech("Sorry, #{category} is not a valid category")
    response_for_alexa.build_response
  end

  # Creates the speech for alexa when the search includes a category
  def format_results_category_speech_for_alexa(response_for_alexa, event, category)
    time_until = time_until(event)
    response_for_alexa.add_speech("The top event in the category #{category} is #{event['title']}. It is happening at #{event['venue_name']}#{time_until}")
  end

  # Make an api call to eventful and return an array of events (probably super huge long awful list)
  def call(call_parameters={})
    # page size is 10 for testing; should be ~50 for production
    if Rails.env.production?
      page_size = "50"
    else
      page_size = "10"
    end

    parameters_hash = { location: call_parameters[:location], date: "Today", sort_order: "popularity", mature: "normal", page_size: page_size, change_multi_day_start: "true" }
    client = EventfulApi::Client.new({})
    response = client.get('/events/search', parameters_hash)
    # hash > "events" > "event" > array of events
    response["events"]["event"]
  end

  #limit the selection to events that have not yet started (OR all-day events if the current time is late in the day)
  def select_not_started(call_list)
    Time.zone = call_list.first['olson_path']
    call_list = call_list.select do |event|
      (event["all_day"] != "0" && Time.zone.now.strftime('%R') < "18:00") || Time.zone.parse(event["start_time"]).future?
    end
  end

  # Run call, then select ten of the call items. Returns array with length 10 or less
  def pick10(events_list)
    events_list[0..9]
  end

  # Run pick ten (or run on output of pick ten, might be more DRY), picks top result. returns top result
  def pick1(ten_events)
    ten_events.first
  end

  # Takes the start time of the event and substracts from Time.now, to show hours until format
  def time_until(event)
    if event['all_day'] != "0"
      ". This is an all-day event."
    else
      Time.zone = event['olson_path']
      current_time = DateTime.parse(Time.zone.now.to_s)
      event_start_date = DateTime.parse(event['start_time'])

      time_until = (event_start_date.hour * 60 + event_start_date.minute) - (current_time.hour * 60 + current_time.minute)
      hour_until = time_until / 60
      minute_until = time_until % 60

      if hour_until == 0
        time_left_phrase = "#{minute_until} min"
      elsif minute_until == 0
        time_left_phrase = "#{hour_until} hr"
      else
        time_left_phrase = "#{hour_until} hr and #{minute_until} min"
      end

      " starting at #{event_start_date.strftime('%l:%M %p')}. You have #{time_left_phrase} to get ready."
    end
  end

  # use the alexa gem to add speech to response for alexa. doesn't need return as it's just side effects we want
  def format_results_speech_for_alexa(response_for_alexa, single_event)
    event_name = single_event['title']
    venue_name = single_event['venue_name']
    time_until = time_until(single_event)
    response_for_alexa.add_speech("#{event_name} is happening at #{venue_name}#{time_until}")
  end

  # use the alexa gem to add text cards to give to alexa's companion app. doesn't need return as it's just side effects we want
  def format_results_text_for_alexa(response_for_alexa, top_ten_events)
    content_for_alexa = top_ten_events.reduce("") do |total_string, event|
      total_string + "\n \n" + generate_single_event_text_for_card(event)
    end
    response_for_alexa.add_card('Simple', 'Top events for tonight!', nil, content_for_alexa)
  end

  # add speech to the response when we return no events
  def format_no_events_found_speech_for_alexa(response_for_alexa)
    response_for_alexa.add_speech("I cannot find anything happening now in #{get_location[:location]}")
  end

  # Create a description of a single event to be added to a card containing all relevant data
  def generate_single_event_text_for_card(event)
    description = find_formatted_description(event)

    if event["all_day"] == "0"
      start_time = DateTime.parse(event['start_time']).strftime('%l:%M %p')
    else
      start_time = "All day"
    end

    "Event: #{event['title']} \n Venue: #{event['venue_name']} \n Time: #{start_time} \n Description: #{description} \n More Info: #{event['url']}"
  end

  # take care of edge case where there's no description within the event hash
  def find_formatted_description(event)
    if event['description']
      format_html_text_to_string(event['description'])
    else
      'We don\'t have any details on this event'
    end
  end

  # remove br tags and &quot; formating and parse it into alexa writable strings
  def format_html_text_to_string(html_text)
    formatted_text = format_html(html_text)
    clip(formatted_text)
  end

  # remove html character codes and html elements
  def format_html(html_text)
    escaped_br_text = html_text.gsub("<br>", "-=-=-0-=")
    text_with_quotes = Nokogiri::HTML(escaped_br_text).text
    text_with_quotes.gsub("-=-=-0-=", "\n")
  end

  # clips the description if it's too long
  def clip(formatted_text)
    if formatted_text.length > 500
      formatted_text[(0...500)] + "..."
    else
      formatted_text
    end
  end

  # uses information from alexa's json object in request to get the zip code of the device
  def get_location
    user = User.find_by(user_id: get_user_id)
    if user
      {location: user.city}
    else
      {location: 'San Francisco'}
    end
  end

  # builds a response for alexa that uses a user and tells them where the new location is set to
  def build_city_set_response(user)
    response = AlexaRubykit::Response.new()
    response.add_speech("I set your city to #{user.city}")
    response.build_response
  end

  # accesses the json alexa sends us to find the user id of the sender
  def get_user_id
    params["session"]["user"]["userId"]
  end

  # accesses the json alexa sends us to find the city given by the sender
  def get_city_from_json
    params["request"]["intent"]["slots"]["city"]["value"]
  end
end
