class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {
        if params["request"]["intent"]
          case params["request"]["intent"]["name"]

          when "WingItIntent"
            render json: create_response(get_location)
          when "SetAddressIntent"
            response = AlexaRubykit::Response.new()
            response.add_speech("hit address intent")
            render json: response.build_response
          end
        else
          render json: create_response(get_location)
        end
      }
    end
  end
end
