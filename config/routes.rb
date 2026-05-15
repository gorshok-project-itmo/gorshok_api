Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  
  devise_for :users, path: '', path_names: { 
    sign_in: 'login', 
    sign_out: 'logout', 
    registration: 'signup' 
  }, controllers: { 
    sessions: 'users/sessions', 
    registrations: 'users/registrations' 
  }
  
  resources :plants do
    collection do
      get :latest
      get :stats
    end
  end
  
  resources :devices do
    member do
      get :watering_status
      post :trigger_watering
    end
    collection do
      get :summary
    end
    
    # Растения привязаны к устройствам
    resources :plants, only: [:index, :create] do
      resources :watering_schedules, only: [:index, :create] do
        collection do
          get :upcoming
        end
      end
    end
  end
  
  # Отдельные маршруты для управления расписаниями и растениями
  resources :plants, only: [:show, :update, :destroy]
  
  resources :watering_schedules, only: [:show, :update, :destroy] do
    member do
      patch :toggle_active
    end
  end
end