class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {
        response = AlexaRubykit::Response.new
        response.add_speech('21:00:00')
        built = response.build_response
        p built
        render json: built
      }
    end
  end
end
