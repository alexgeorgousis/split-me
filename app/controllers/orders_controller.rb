class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy process_receipt review_receipt bill_breakdown ]

  # GET /orders or /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1 or /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to orders_path, notice: "Order was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /orders/1/process_receipt
  def process_receipt
    if params[:auto_match]
      matches_count = @order.auto_match_all_ingredients!
      redirect_to review_receipt_order_path(@order), notice: "Auto-matched #{matches_count} ingredients!"
    elsif @order.process_receipt!
      redirect_to review_receipt_order_path(@order), notice: "Receipt processed successfully!"
    else
      redirect_to @order, alert: "Failed to process receipt. Please check the file format."
    end
  end

  # GET /orders/1/review_receipt
  def review_receipt
    redirect_to @order, alert: "Receipt not processed yet." unless @order.receipt_processed?
  end

  # GET /orders/1/bill_breakdown
  def bill_breakdown
    unless @order.bill_splitting_ready?
      redirect_to @order, alert: "Order is not ready for bill splitting. Please ensure receipt is processed and all meals have matched ingredients."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def order_params
      params.expect(order: [ :total, :receipt, meal_ids: [] ])
    end
end
