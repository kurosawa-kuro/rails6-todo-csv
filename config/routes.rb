Rails.application.routes.draw do
  root 'todos#index'
  resources :todos do
    collection do
      get :export, to: "todos#export", as: :export
      post :import, to: "todos#import", as: :import
    end
  end
end