Rafael::Application.routes.draw do

  resources :review_journals


  resources :statuses, only: [:edit,:update, :reviewed, :index] do
    get :reviewed, on: :member
  end

  root :to => 'home#index' # Este deve estar em ultimo nesta lista (referencia)

  resources :type_params

  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  resources :quicks

  resources :stoichiometric, only: [:new,:create]

  scope(path_names: { new: 'tools' }) do
    resources :dynamic, only: [:new,:create] do
       post :substitutions, on: :collection
       post :kinetic, on: :collection
       post :reduction, on: :collection
       post :fluxes, on: :collection
    end
  end

  resources :home, only: [:index]

  get :my_repository, to: "organisms#my_organisms"

  resources :organisms, path: :repository do
    resources :attached_files, only: [:new,:create,:destroy] do
      get :download, on: :member
    end

    get :download_all, on: :member
    get :download, on: :member
    resources :organism_associations, path: :associations, only: [:new,:create,:destroy]
    resources :associated_models do
      get :download_all, on: :member
      get :associate, on: :member
      resources :articles, only: [:new,:create,:destroy], path: :sbmls do
        get :download, on: :member
      end
      resources :authorizations, only: [:new,:create,:destroy]
    end
  end

  resources :documentation, only: [:index] do
    get :contact, on: :collection
  end

  resources :links, only: [:index]

end
