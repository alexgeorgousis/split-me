class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy process_receipt batch_update_receipt_items ]

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

    if @order.save
      redirect_to orders_path, notice: "Order was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      redirect_to orders_path, notice: "Order was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @order.destroy!
    redirect_to orders_path, notice: "Order was successfully destroyed.", status: :see_other
  end

  def process_receipt
    unless @order.receipt&.file&.attached?
      redirect_to orders_path, alert: "No receipt file attached."
      return
    end

    @order.process_receipt!
    redirect_to order_path(@order), notice: "Receipt processed successfully!"
  rescue => e
    redirect_to @order, alert: "Failed to process receipt: #{e.message}"
  end

  def batch_update_receipt_items
    updates = JSON.parse(params[:updates])

    updates.each do |update|
      receipt_item = @order.receipt.receipt_items.find(update["id"])

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
