require 'rails_helper'

RSpec.describe AlexaInterfaceController, :type => :controller do
  describe '#recommend' do
    let(:user){User.create(user_id: 'userId', city: 'San Francisco')}
    let(:json){{ 'format' => 'json',
               'request' => { },
               "session" => { 'user' => { 'userId' => "userId"} } }}

    it 'responds with a default if there is no intent given' do
      json['request'] = nil

      post :recommend, params: json
      expect(JSON.parse(response.parsed_body)['response']['card']['title']).to eq("Top events for tonight!")
    end

    it 'responds with default if WingItIntent is the intent' do
      json['request'] = {'intent' => {'name' => 'WingItIntent'}}
      post :recommend, params: json
      expect(JSON.parse(response.parsed_body)['response']['card']['title']).to eq("Top events for tonight!")
    end

    it 'responds with general help response if AMAZON.HelpIntent is the intent' do
      json['request'] = {'intent' => {'name' => 'AMAZON.HelpIntent'}}
      post :recommend, params: json
      expect(JSON.parse(response.parsed_body)['response']['outputSpeech']['text']).to match(/Try asking: Alexa,.*/)
    end

    it 'responds by setting the category and searching if SetCategryIntent is the intent' do
      json["request"] = {"intent" => {'name' => 'SetCategoryIntent', "slots" => {"category" => {"value" => 'category'}}}}
      post :recommend, params: json
      expect(JSON.parse(response.parsed_body)['response']['outputSpeech']['text']).to eq("Sorry, category is not a valid category")
    end

    it 'responds with category_help_response if CategoryHelpIntent is the intent' do
      json['request'] = {'intent' => {'name' => 'CategoryHelpIntent'}}
      post :recommend, params: json
      expect(JSON.parse(response.parsed_body)['response']['outputSpeech']['text']).to eq("Here are some popular categories you can search: Food, Music, Sports, Nightlife, Meetups. Please refer to the card for the full list.")
    end

    it 'responds with the city_help_response if CityHelpIntent is the intent' do
      json['request'] = {'intent' => {'name' => 'CityHelpIntent'}}
      post :recommend, params: json
      expect(JSON.parse(response.parsed_body)['response']['outputSpeech']['text']).to eq("You have not set your city yet. The default city is San Francisco")
    end

    it 'will set a user location when intent is SetCityIntent' do
      json = { 'format' => 'json',
               'request' => { 'intent' => { 'name' => 'SetCityIntent', 'slots' => { 'city' => { 'value' => "City" } } } },
               "session" => { 'user' => { 'userId' => "userId"} } }
      post :recommend, params: json
      expect(assigns(:user)).to be_kind_of(User)
      expect(assigns(:user).user_id).to eq("userId")
      expect(assigns(:user).city).to eq("City")
    end

    it 'will return an easter egg if the EasterEggs is triggered' do
      json['request'] = {'intent' => {'name' => 'EasterEggs'}}
      post :recommend, params: json

      expect(JSON.parse(response.parsed_body)['response']['outputSpeech']['text']).to match (/The Wild Pigs graduation party is happening at Sparks Social SF starting at  6:30 PM. You have (\d+ hr and \d+ min|\d+ hr|\d+ min) to get ready. Time to celebrate!/)
    end

  end
end
