class OligoOrdersController < ApplicationController
  # GET /oligo_orders
  # GET /oligo_orders.xml
  def index
    @oligo_orders = OligoOrder.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @oligo_orders }
    end
  end

  # GET /oligo_orders/1
  # GET /oligo_orders/1.xml
  def show
    @oligo_order = OligoOrder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @oligo_order }
    end
  end

  # GET /oligo_orders/new
  # GET /oligo_orders/new.xml
  def new
    @oligo_order = OligoOrder.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @oligo_order }
    end
  end

  # GET /oligo_orders/1/edit
  def edit
    @oligo_order = OligoOrder.find(params[:id])
  end

  # POST /oligo_orders
  # POST /oligo_orders.xml
  def create
    @oligo_order = OligoOrder.new(params[:oligo_order])

    respond_to do |format|
      if @oligo_order.save
        flash[:notice] = 'OligoOrder was successfully created.'
        format.html { redirect_to(@oligo_order) }
        format.xml  { render :xml => @oligo_order, :status => :created, :location => @oligo_order }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @oligo_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /oligo_orders/1
  # PUT /oligo_orders/1.xml
  def update
    @oligo_order = OligoOrder.find(params[:id])

    respond_to do |format|
      if @oligo_order.update_attributes(params[:oligo_order])
        flash[:notice] = 'OligoOrder was successfully updated.'
        format.html { redirect_to(@oligo_order) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @oligo_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /oligo_orders/1
  # DELETE /oligo_orders/1.xml
  def destroy
    @oligo_order = OligoOrder.find(params[:id])
    @oligo_order.destroy

    respond_to do |format|
      format.html { redirect_to(oligo_orders_url) }
      format.xml  { head :ok }
    end
  end
end
