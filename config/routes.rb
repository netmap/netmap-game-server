Netmap::Application.routes.draw do
  get 'map_tile/:zoom/:x/:y(.:format)' => 'map_tiles#show', as: :map_tile
  get 'map' => 'map_tiles#index', as: :map_tiles

  resources :players

  resources :users

  authpwn_session
  root to: 'session#show'

  get 'manual/:name' => 'manual#show', as: :manual_section
  get 'manual(:.format)' => 'manual#index', as: :manual
end
