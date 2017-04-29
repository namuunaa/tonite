class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {
        response = AlexaRubykit::Response.new
        response.add_speech('Clearly not a date with James because you did not make the date James app')
        built = response.build_response
        p built
        render json: built
      }
    end
  end
end
