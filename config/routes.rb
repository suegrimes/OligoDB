ActionController::Routing::Routes.draw do |map|
  map.resources :users

  map.resource :session

  map.signup  '/signup', :controller => 'users',   :action => 'new' 
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.resources :pool_wells

  map.resources :oligo_wells

  map.connect '', :controller => "oligo_designs", :action => "welcome" 
  
  map.resources :oligo_designs

  map.resources :researchers
  
  map.resources :syntheses

  map.resources :pool_plates

  map.resources :aliquots

  map.resources :oligo_plates
  
  map.resources :oligo_orders

  map.resources :uploads

  map.resources :regions
  
  map.designquery 'designquery', :controller => 'oligo_designs', :action => 'select_gene'
  map.uploadfile 'uploadfile', :controller => 'uploads', :action => 'new'
  map.uploadselector 'uploaddesign', :controller => 'oligo_designs', :action => 'upload_file'
  map.inventoryquery 'inventoryquery', :controller => 'inventory', :action => 'selectparams'
  map.selectthreshold 'selectthreshold', :controller => 'inventory', :action => 'selectthreshold'
  map.listinventory 'listinventory', :controller => 'inventory', :action => 'list_inventory'
  map.poolparams 'poolparams', :controller => 'pool_plates', :action => 'poolparams'
  map.wellvolquery 'wellvolquery', :controller => 'inventory', :action => 'selectthreshold'
  map.notimplemented 'notimplemented', :controller => 'dummy', :action => 'notimplemented'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #map.resources :recipes, :collection => { :search => :get }
  
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
