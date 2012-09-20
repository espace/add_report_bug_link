if Rails::VERSION::MAJOR >= 3
  RedmineApp::Application.routes.draw do
    match 'issues/my_new', :controller => 'issues', :action => 'my_new', :via => [:get, :post], :as => 'my_new_issue'

  # resources :projects, :only => [:my_new] do
  #   resources :issues, :only => [:my_new] do
  #     collection do
  #       match 'my_new', :via => [:get, :post]
  #     end
  #   end
  # end

    # match 'issues/my_new', :to => 'issues#my_new', :as => 'issue_form'
    # resources :projects do
    #   resources :
    #   get :my_new, :on => :collection
    # end
    # issue form update
    # match 'issues/new', :controller => 'issues', :action => 'new', :via => [:put, :post], :as => 'issue_form'

    # :controller => 'issues', :action => 'new', :via => [:put, :post]
    # match 'projects/:project_id/boards/:board_id/manage', :to => 'boards_watchers#manage', :via => [:get, :post]
  end
else
 #  ActionController::Routing::Routes.draw do |map|
 #    map.connect 'issues/new', :controller => 'issues', :action => 'new', :via => [:put, :post]
 # end
end