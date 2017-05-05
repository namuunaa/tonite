class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  include AlexaInterfaceHelper
  include AlexaHelpIntentHelper
  include AlexaEastereggHelper
end
