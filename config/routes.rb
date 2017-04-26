Rails.application.routes.draw do
  resources :quotes
  devise_for :members, :controllers => {:sessions => 'sessions', :passwords => 'passwords'}
  resources :interpretations do
    collection do
      get 'ids'
    end
  end
  root :to => 'birthdays#new'
  resources :lookups
  resources :birthdays do
    member do
      get :replace_card
    end
  end
  resources :places
  resources :spreads
  resources :cards
  resources :faces
  resources :suits
  
  post '/member_save' => 'members#create', :as => 'member_save'
  put '/member_assign_zodiac/:id' => 'members#update', :as => 'member_assign_zodiac'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
