ActionController::Routing::Routes.draw do |map|
  map.connect '', :controller => "oligo_designs", :action => "welcome" 
  map.signup  '/signup', :controller => 'users',   :action => 'new' 
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.help '/help', :controller => 'help', :action => 'index'
  
  # Routes for genes, target regions
  map.resources :genes
  map.resources :target_regions
  map.resources :selector_sites  
  
  # Routes for oligo designs (selectors)
  map.resources :archive_oligo_designs 
  map.resources :pilot_oligo_designs
  map.resources :oligo_designs
  map.resources :vectors
  map.exportd 'export_designs',        :controller => 'oligo_designs',   :action => 'export'
  
  # Oligo design queries
  map.show_oligo 'show_oligo',         :controller => 'oligo_designs', :action => 'show', :id => :id
  map.designquery 'designquery',       :controller => 'oligo_designs', :action => 'select_project'
  map.oligoparams 'oligoparams',       :controller => 'oligo_designs', :action => 'select_params'
  map.list_selected 'list_oligos',     :controller => 'oligo_designs', :action => 'list_selected'
  
  # Routes for oligo synthesis orders/files
  map.synth_order 'synth_order',       :controller => 'synth_orders', :action => 'new_order'
  map.synth_params 'synth_params',     :controller => 'synth_orders', :action => 'select_params'
  map.synth_files 'synth_files',       :controller => 'synth_orders',  :action => 'list_files'
  map.show_synth  'show_synth',        :controller => 'synth_orders',  :action => 'show_files'
  map.del_synth  'del_synth',          :controller => 'synth_orders',  :action => 'delete_file'
  
  # Routes for synthesized oligos
  map.resources :synth_oligos
  
  # Synthesized oligo queries
  map.inventoryquery 'inventoryquery', :controller => 'synth_oligos',  :action => 'select_project'
  map.inv_params 'inv_params',         :controller => 'synth_oligos',  :action => 'select_genes_and_ver'
  map.list_inventory 'list_inventory', :controller => 'synth_oligos',  :action => 'list_inventory'
  map.export_inventory 'export_inventory', :controller => 'synth_oligos', :action => 'export_inventory'
  
  # Routes for oligo plate/well inventory (& general inventory)
  map.resources :oligo_plates
  map.resources :oligo_wells
  
  map.resources :aliquots
  map.resources :storage_locations
  
  map.plate_copy 'plate_copy',         :controller => 'oligo_plates',  :action => 'copy_params'
  map.plates_edit 'plates_edit',       :controller => 'oligo_plates',  :action => 'edit_multi', :method => :get
  map.wellvolquery 'wellvolquery',     :controller => 'oligo_wells',   :action => 'selectthreshold'
  
  # Routes for pool inventory
  map.resources :pool_plates
  map.resources :pool_wells
  map.resources :pools
  map.resources :subpools
  
  map.addwells 'addwells',             :controller => 'pools',         :action => 'addwells'
  map.showwells 'showwells',           :controller => 'pools',         :action => 'showwells'
  map.pools_edit 'pools_edit',         :controller => 'pools',         :action => 'edit_multi', :method => :get
  map.pool_vol 'pool_vol',             :controller => 'pools',         :action => 'upd_pool_vol'
  map.wells_edit 'wells_edit',         :controller => 'pool_wells',    :action => 'edit_multi', :method => :get
  map.subpools_edit 'subpools_edit',   :controller => 'subpools',      :action => 'edit_multi', :method => :get
  map.subpool_dtls 'subpool_dtls',     :controller => 'subpools',      :action => 'show_dtls'
  map.subpool_conc 'subpool_conc',     :controller => 'subpools',      :action => 'upd_conc'
  
  map.export_pool 'export_pool',       :controller => 'subpools',      :action => 'export_pool'
  
  # Routes for BioMek run templates/files
  map.biomek_new 'biomek_new',         :controller => 'biomek_runs',   :action => 'biomek_new'
  map.biomek_files 'biomek_files',     :controller => 'biomek_runs',   :action => 'list_files'
  map.show_biomek 'show_biomek',       :controller => 'biomek_runs',   :action => 'show_files'
  map.del_biomek 'del_biomek',         :controller => 'biomek_runs',   :action => 'delete_file'
  map.exportb 'export_biomek',         :controller => 'biomek_runs',     :action => 'export_biomek'

  # Routes for general uploads
  map.resources :uploads
  map.uploadfile 'uploadfile',      :controller => 'uploads', :action => 'new'
  
  # Routes for other downloads
  map.zip_download 'zip_download',  :controller => 'oligo_designs',   :action => 'zip_download'
  
  # Routes for supporting tables
  map.resources :researchers
  map.resources :projects
  map.resources :users
  map.resources :versions
  map.resources :flag_defs
  map.resource  :session  
  
  # Miscellaneous, Testing
  map.notimplemented 'notimplemented', :controller => 'dummy',         :action => 'notimplemented'
  map.testing 'testing',               :controller => 'dummy',         :action => 'test'
  
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
