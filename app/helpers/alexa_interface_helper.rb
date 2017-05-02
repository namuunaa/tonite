module AlexaInterfaceHelper

  # uses everything and returns a full response object to send to alexa
  def create_response(call_parameters)
    response_for_alexa = AlexaRubykit::Response.new
    response = call(call_parameters)
    not_started = select_not_started(response)
    top_ten = pick10(not_started)
    top_one = pick1(top_ten)
    format_speech_for_alexa(response_for_alexa, top_one)
    format_text_for_alexa(response_for_alexa, top_ten)
    response_for_alexa.build_response
  end

  # Make an api call to eventful and return an array of events (probably super huge long awful list)
  def call(call_parameters={})
    # page size is 10 for testing; should be ~500 for production
    if Rails.env.production?
      page_size = "500"
    else
      page_size = "10"
    end

    parameters_hash = { location: "San Francisco", date: "Today", sort_order: "popularity", mature: "normal", page_size: page_size, change_multi_day_start: "true" }
    if call_parameters[:location]
      parameters_hash[:location] = call_parameters[:location]
    end
    client = EventfulApi::Client.new({})
    response = client.get('/events/search', parameters_hash)
    # hash > "events" > "event" > array of events
    response["events"]["event"]
  end

  #limit the selection to events that have not yet started (OR all-day events if the current time is late in the day)
  def select_not_started(call_list)
    # call_list = call_list.select do |event|
    #   event["all_day"] && event["start_time"]
    # end
    call_list = call_list.select do |event|
      Time.zone = event['olson_path']
      (event["all_day"] != "0" && Time.zone.now.strftime('%R') < "18:00") || Time.zone.parse(event["start_time"]).future?
    end
    # call_list
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

      current_total_minute = current_time.hour * 60 + current_time.minute
      event_total_minute = event_start_date.hour * 60 + event_start_date.minute
      time_until = event_total_minute - current_total_minute
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


    # if hour_until == 1
    #   if minute_until == 1
    #     "#{hour_until} hour and #{minute_until} minute"
    #   else
    #     "#{hour_until} hour and #{minute_until} minutes"
    #   end
    # elsif minute_until == 1
    #   "#{hour_until} hours and #{minute_until} minute"
    # elsif hour_until == 0
    #   "#{minute_until} minutes"
    # elsif minute_until == 0
    #   "#{hour_until} hours"
    # else
    #   "#{hour_until} hours and #{minute_until} minutes"
    # end
  end

  # use the alexa gem to add speech to response for alexa. doesn't need return as it's just side effects we want
  def format_speech_for_alexa(response_for_alexa, single_event)
    event_name = single_event['title']
    venue_name = single_event['venue_name']
    # start_date = single_event['start_time']
    # start_time = DateTime.parse(start_date).strftime('%l:%M %p')
    time_until = time_until(single_event)
    response_for_alexa.add_speech("#{event_name} is happening at #{venue_name}#{time_until}")
  end

  # use the alexa gem to add text cards to give to alexa's companion app. doesn't need return as it's just side effects we want
  def format_text_for_alexa(response_for_alexa, top_ten_events)
    content_for_alexa = top_ten_events.reduce("") do |total_string, event|
      total_string + "\n \n" + generate_single_event_text_for_card(event)
    end
    # We'd like to use Standard cards so we can eventually include images but the alexa wants text as an argument instead of content for a standard card and the gem doesn't do that. Thus we have to use a simple card
    response_for_alexa.add_card('Simple', 'Top events for tonight!', nil, content_for_alexa)
  end

  def generate_single_event_text_for_card(event)
    event_name = event['title']
    venue_name = event['venue_name']
    start_date = event['start_time']
    url = event['url']
    description = find_formatted_description(event)

    if event["all_day"] == "0"
      start_time = DateTime.parse(start_date).strftime('%l:%M %p')
    else
      start_time = "All day"
    end

    "Event: #{event_name} \n Venue: #{venue_name} \n Time: #{start_time} \n Description: #{description} \n More Info: #{url}"
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
  # can refactor with sanitize for nokogiri
  def format_html_text_to_string(html_text)
    formatted_text = format_html(html_text)
    clip(formatted_text)
  end

  def format_html(html_text)
    escaped_br_text = html_text.gsub("<br>", "-=-=-0-=")
    text_with_quotes = Nokogiri::HTML(escaped_br_text).text
    text_with_quotes.gsub("-=-=-0-=", "\n")
  end

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
      {}
    end
  end

  # builds a response for alexa that uses a user and tells them where the new location is set to
  def build_city_set_response(user)
    response = AlexaRubykit::Response.new()
    response.add_speech("Set your city to #{user.city}")
    response.build_response
  end

  # accesses the json alexa sends us to find the user id of the sender
  def get_user_id
    params["session"]["user"]["userId"]
  end

  def get_city_from_json
    params["request"]["intent"]["slots"]["city"]["value"]
  end

end
