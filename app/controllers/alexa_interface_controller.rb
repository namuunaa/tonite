class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {
        if params["request"]["intent"]
          case params["request"]["intent"]["name"]

          when "WingItIntent"
            render json: create_response(get_location)
          when "SetCityIntent"
            city = params["request"]["intent"]["slots"]["city"]["value"]
            user_id = params["session"]["user"]["userId"]
            p "user_id is #{user_id}"
            @user = User.find_or_initialize_by(user_id: user_id)
            @user.city = city
            @user.save
            response = AlexaRubykit::Response.new()
            response.add_speech("Set your city to #{@user.city}")
            render json: response.build_response
          end
        else
          render json: create_response(get_location)
        end
      }
    end
  end
end
