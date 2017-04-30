class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {
        render json: create_response({})
      }
    end
  end
end
