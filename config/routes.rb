Netmap::Application.routes.draw do
  get 'map_tile/:zoom/:x/:y(.:format)' => 'map_tiles#show', as: :map_tile
  get 'map' => 'map_tiles#index', as: :map_tiles

  authpwn_session
  root to: 'session#show'
end
