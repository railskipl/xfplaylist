class MainSite 
  def self.matches?(request)
    request.subdomain.blank? || request.subdomain == 'www'
  end
end

Subscriptions::Application.routes.draw do |map|
  # Routes for the public site
  constraints MainSite do
    # Homepage
    root :to => "content#index"
    map.connect  '/home', :controller=>'home', :action=>'index'
    map.connect '/pages/:id', :controller=>'blog', :action=>'page'
   map.connect '/contacts', :controller=>'blog', :action=>'contact'
   
    # Account Signup Routes
    match '/signup' => 'accounts#plans', :as => 'plans'
    match '/signup/d/:discount' => 'accounts#plans'
    match '/signup/thanks' => 'accounts#thanks', :as => 'thanks'
    match '/signup/create/:discount' => 'accounts#create', :as => 'create', :defaults => { :discount => nil }
    match '/signup/:plan/:discount' => 'accounts#new', :as => 'new_account'
    match '/signup/:plan' => 'accounts#new', :as => 'new_account'
   
    match '/signin' => 'presessions#new', :as => 'signin' 
    match '/preauthenticate' => 'presessions#create', :as => 'preauthentication'
    
    # Catch-all that just loads views from app/views/content/* ...
    # e.g, http://yoursite.com/content/about -> app/views/content/about.html.erb
    #
    match '/content/:action' => 'content'
  end

  root :to => "songs#index"

  devise_for :users

  #
  # Account / User Management Routes
  #
  resources :users
  
  resource :account do 
    member do
      get :dashboard, :thanks, :plans, :canceled
      match :billing, :paypal, :plan, :plan_paypal, :cancel
    end
   resources :pages
  end

  # Custom routes specific to our app
  namespace "saas_admin" do
    resources :pages do
      put "reposition", :on => :member
    end
    
    resources :posts
    resources :songs
    resources :messages
  end

  resources :pages, :only => :show
  resources :posts, :only => [ :index, :show ]
  match     "playlist" => "songs#index"
  post      "songs/flag" => "songs#flag",     :as => "flag"

  get    "contact"      => "messages#new",    :as => "contact"
  post   "/home" => "messages#create", :as => "deliver"
  get    "contact/sent" => "messages#sent",   :as => "sent"


end
