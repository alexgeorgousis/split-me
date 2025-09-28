class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy bill_breakdown process_receipt batch_update_receipt_items ]

  def index
    @orders = Order.all
  end

  def show
  end

  def new
    @order = Order.new
  end

  def edit
  end

  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to orders_path, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

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

  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to orders_path, notice: "Order was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def bill_breakdown
    unless @order.receipt.processed?
      redirect_to @order, alert: "Receipt not processed yet."
    end
  end

  def process_receipt
    if @order.process_receipt!
      redirect_to bill_breakdown_order_path(@order), notice: "Receipt processed successfully!"
    else
      redirect_to @order, alert: "Failed to process receipt. Please check the file format."
    end
  rescue => e
    redirect_to @order, alert: "Failed to process receipt: #{e.message}"
  end

  def batch_update_receipt_items
    updates = JSON.parse(params[:updates])

    updates.each do |update|
      receipt_item = @order.receipt_items.find(update["id"])

      if update["split_mode"] == "remove"
        receipt_item.destroy!
      else
        receipt_item.update!(
          selected: update["selected"],
          split_mode: update["split_mode"]
        )
      end
    end

    head :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private
    def set_order
      @order = Order.find(params.expect(:id))
    end

    def order_params
      params.require(:order).permit(meal_ids: [], receipt_attributes: [ :file ])
    end
end
