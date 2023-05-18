Rails.application.routes.draw do
  resources :deliveries do
    collection do
      get :entrance
    end
    member do
      get :access
    end
  end
  
  resources :interviews do
    collection do
      get :review
    end
  end
  resources :celestials
  resources :quotes
  devise_for :members, :controllers => {:sessions => 'sessions', :passwords => 'passwords'}
  
  authenticated :member do
    root :to => 'birthdays#mine'
  end
  
  resources :subscriptions, :only => [:new, :create, :update] do
    member do
      get :manage
    end
    collection do
      post :upgrade
      delete :cancel
    end
  end
  
  resources :interpretations do
    collection do
      get 'ids'
    end
  end
  unauthenticated do
    root to: 'birthdays#new', as: :unauthenticated_root
  end
  resources :birthdays do
    member do
      get :replace_card
      get :personality_for_zodiac
      get :browse
    end
  end
  resources :places
  resources :spreads
  resources :cards
  resources :faces
  resources :suits
  resources :members, :only => :index
  
  get '/calendars/mine' => 'calendars#mine'
  get '/calendars/ours' => 'calendars#ours'
  
  get '/guidances/prompt' => 'guidances#prompt'
  get '/guidances/show' => 'guidances#show'
  post '/guidances/show' => 'guidances#show'
  get '/guidances/daily_card' => 'guidances#daily_card'
  get '/guidances/card52' => 'guidances#card52'
  get '/guidances/year_card' => 'guidances#year_card'
  post '/guidances/payment' => 'guidances#payment'
  get '/guidances/initialize_payment' => 'guidances#initialize_payment'
  get '/guidances/lookup_cards' => 'guidances#lookup_cards'

  post '/member_save' => 'members#create', :as => 'member_save'
  put '/member_assign_zodiac/:id' => 'members#update', :as => 'member_assign_zodiac'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
