Netmap::Application.routes.draw do
  get 'map_tile/:zoom/:x/:y(.:format)' => 'map_tiles#show'
  get 'map' => 'map_tiles#index'

  root to: 'session#index'
end
