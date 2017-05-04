class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  include AlexaInterfaceHelper
  include AlexaHeplpIntentHelper
end
