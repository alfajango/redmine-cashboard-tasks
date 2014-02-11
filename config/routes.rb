# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :cashboard_tasks, :only => [:new, :create, :edit, :update] do
  collection do
    get :get_project_list
    get :get_projects
    get :get_line_items
    get :new_issue_form
    get 'import' => 'cashboard_tasks#import_new'
    post 'import' => 'cashboard_tasks#import_create'
  end
end
