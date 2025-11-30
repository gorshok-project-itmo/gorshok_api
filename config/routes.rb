Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
             controllers: {
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
    
    # Добавляем вложенные маршруты для расписаний полива
    resources :watering_schedules, only: [:index, :create] do
      collection do
        get :upcoming
      end
    end
  end

  # Отдельные маршруты для управления расписаниями
  resources :watering_schedules, only: [:show, :update, :destroy] do
    member do
      patch :toggle_active
    end
  end
end
