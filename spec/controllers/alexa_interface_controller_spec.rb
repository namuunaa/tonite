require 'rails_helper'

RSpec.describe AlexaInterfaceController, :type => :controller do
  describe '#recommend' do
    it 'accepts returns a json object to a json post request' do
      json = { :format => 'json', :application => { :name => "foo", :description => "bar" }, :request => {:foo => 'bar'} }
      post :recommend, json
      expect(response.header['Content-Type']).to include 'application/json'
    end

    it 'will set a user location when intent is SetCityIntent' do
      json = { :format => 'json', :application => { :name => "foo", :description => "bar" }, :request => { :intent => { :name => 'SetCityIntent', :slots => { :city => { :value => "City" } } } }, :session => { :user => { :user_id => "userId"} } }
      post :recommend, json
      expect(assigns(:user)).to be_kind_of(User)
      expect(assigns(:user).user_id).to eq("userId")
      expect(assigns(:user).city).to eq("City")
    end
    # spy on, runs create response
    it 'will run default without an intent'

  end
end
