class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {
        response = AlexaRubykit::Response.new
        response.add_speech('Clearly not a date with James because you did not make the date James app')
        render json: response.build_response
      }
    end
  end
end
