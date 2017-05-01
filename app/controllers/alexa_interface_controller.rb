class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {
        case params["request"]["intent"]["name"]

        when "WingItIntent"
          render json: create_response(get_location)
        when "SetAddressIntent"
          response = AlexaRubykit.new()
          response.add_speech("hit address intent")
          render json: response.build_response
        end
      }
    end
  end
end
