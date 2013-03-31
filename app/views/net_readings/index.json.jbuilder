json.array!(@net_readings) do |net_reading|
  json.extract! net_reading, :player_id, :digest, :json_data
  json.url net_reading_url(net_reading, format: :json)
end
