class NetReadingsController < ApplicationController
  before_action :ensure_user_logged_in, only: [:create]
  before_action :ensure_user_is_admin, only: [:index, :show]

  # GET /net_readings
  # GET /net_readings.json
  def index
    @net_readings = NetReading.all
  end

  # GET /net_readings/1
  # GET /net_readings/1.json
  def show
    @net_reading = NetReading.find params[:id]
  end

  # POST /net_readings
  # POST /net_readings.json
  def create
    player = current_user.player
    data_pack = request.body.read

    readings = data_pack.split("\n").reject(&:empty?).map do |json_data|
      reading = NetReading.new player: player, json_data: json_data
      if NetReading.where(digest: reading.digest).first
        # Gracefully skip the readings that were already uploaded.
        # NOTE: this can happen if the network goes down right before a client
        #       gets the HTTP 200 that acknowledges an upload.
        nil
      else
        reading.save!
        reading
      end
    end
    readings.reject!(&:nil?)

    respond_to do |format|
      format.html { render text: 'OK' }
      format.json { render text: '{}', status: :ok }
    end
  end
end
