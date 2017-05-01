class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {
        p params
        render json: create_response({})
      }
    end
  end
end
