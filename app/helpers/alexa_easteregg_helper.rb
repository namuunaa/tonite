module AlexaEastereggHelper
  include AlexaInterfaceHelper

  def get_easter_egg
    response_for_alexa = AlexaRubykit::Response.new

    party = {
      'start_time' => '2017-05-05 18:30', 'olson_path' => 'America/Los_Angeles', 'all_day' => "0"
    }
    time_until_event = time_until(party)

    response_for_alexa.add_speech("The Wild Pigs graduation party is happening at Sparks Social SF#{time_until_event} Time to celebrate!")
    response_for_alexa.build_response
  end
end

