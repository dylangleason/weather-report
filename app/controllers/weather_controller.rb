class WeatherController < ApplicationController
  ##
  # Handle a request to render the main application view, including an
  # input form where the user can enter their zipcode.
  #
  def index
  end

  ##
  # Handle a request to obtain the current Weather Report given a
  # +zipcode+ parameter, returning a JSON response for use via XHR
  # request.
  #
  def show
    # TODO: implement
    logger.debug params[:zipcode]
    render json: { "temp" => 43 }
  end
end
