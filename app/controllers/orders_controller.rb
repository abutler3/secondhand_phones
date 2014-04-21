class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :seller]

  def sales
    @orders = Order.all.where(seller: current_user).order("created_at DESC")
    # On the sales page, show all orders where the current user is the seller.
    # Display when they were created so the most recent order is first
  end

  def purchases
    @orders = Order.all.where(buyer: current_user).order("created_at DESC")
    # On the purchases page, show all purchases where the current user is the buyer.
    # Display when they were created so the most recent purchase is first
  end

  # # GET /orders
  # # GET /orders.json
  # def index
  #   @orders = Order.all
  # end

  # GET /orders/1
  # GET /orders/1.json
  # def show
  # end

  # GET /orders/new
  def new
    @order = Order.new
    @listing = Listing.find(params[:listing_id])
    # Find the id of the listing you want to buy in the url
  end

  # GET /orders/1/edit
  # def edit
  # end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    @listing = Listing.find(params[:listing_id])
    @seller = @listing.user
    # The seller is the same as the user who created the listing

    @order.listing_id = @listing.id
    # Find the id of the listing you want to buy in the url
    @order.buyer_id = current_user.id
    # When you create the order
    # Fill in the buyer_id column with the current_user.id
    @order.seller_id = @seller.id

    Stripe.api_key = ENV["STRIPE_API_KEY"]
    # Tell Stripe the secret key
    token = params[:stripeToken]
    # Looks in form data. Pulls out stripeToken and save it in var called token

    begin
      # Creates a new Stripe charge. Located on stripe website. Charges/create a new change in docs
      charge = Stripe::Charge.create(
        :amount => (@listing.price * 100).floor,
        # Set the amount to the listing price and convert into cents. Floor makes it an integer not a decimal
        :currency => "usd",
        :card => token
        # Card number is in the token
        )
        flash[:notice] = "Thanks for ordering!"
    rescue Stripe::CardError => e
      # If error, show error message. Like if the card was declined
      flash[:danger] = e.message
    end

    # Transfer money to receipient
    transfer = Stripe::Transfer.create(
      :amount => (@listing.price * 95).floor,
      # 95 percent to seller. 5 for me. price converted to cents
      :currency => "usd",
      :recipient => @seller.recipient
    )

    respond_to do |format|
      if @order.save
        format.html { redirect_to root_url }
        format.json { render action: 'show', status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  # def update
  #   respond_to do |format|
  #     if @order.update(order_params)
  #       format.html { redirect_to @order, notice: 'Order was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @order.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /orders/1
  # DELETE /orders/1.json
  # def destroy
  #   @order.destroy
  #   respond_to do |format|
  #     format.html { redirect_to orders_url }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:address, :city, :state)
    end
end
