require 'rails_helper'

RSpec.describe AlexaInterfaceController, :type => :controller do
  describe '#recommend' do
    xit 'accepts returns a json object to a json post request' do
      json = { 'format' => 'json',
               'request' => { 'intent' => { 'name' => 'SetCityIntent', 'slots' => { 'city' => { 'value' => "City" } } } },
               "session" => { 'user' => { 'userId' => "userId"} } }
      post :recommend, json
      ap response
      expect(response).to be(1)
    end

    it 'responds with a default if there is no intent given'

    it 'responds with default if WingItIntent is the intent'

    it 'responds with general help response if AMAZON.HelpIntent is the intent'

    it 'responds by setting the category if SetCategryIntent is the intent'

    it 'responds with category_help_response if CategoryHelpIntent is the intent'

    it 'responds with the city_help_response if CityHelpIntent is the intent'

    it 'will set a user location when intent is SetCityIntent' do
      json = { 'format' => 'json',
               'request' => { 'intent' => { 'name' => 'SetCityIntent', 'slots' => { 'city' => { 'value' => "City" } } } },
               "session" => { 'user' => { 'userId' => "userId"} } }
      post :recommend, json
      expect(assigns(:user)).to be_kind_of(User)
      expect(assigns(:user).user_id).to eq("userId")
      expect(assigns(:user).city).to eq("City")
    end

  end
end
