M1830::Application.routes.draw do
  resources :game_sessions do
    member do
      post 'command'
      post 'final_score'
    end
  end
  
  get "/help" => 'game_sessions#help', :as => :help
  get "/settings" => 'game_sessions#settings', :as => :settings
  
  root 'game_sessions#index'
end
