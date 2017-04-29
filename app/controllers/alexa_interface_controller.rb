class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {}
    end
  end
end
