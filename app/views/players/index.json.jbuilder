json.array!(@players) do |player|
  json.extract! player, :name
  json.url player_url(player, format: :json)
end