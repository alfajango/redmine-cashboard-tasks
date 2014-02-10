# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :cashboard_tasks, :only => [:new, :create, :edit, :update] do
  collection do
    get :get_project_list
    get :get_projects
  end
end
