class Admin::GearItemsController < Admin::BaseController
  before_action :set_gear_item, only: [ :edit, :update, :destroy, :purge_product_image ]

  def index
    @gear_items = GearItem.all.order(position: :asc, created_at: :desc)

    # Filter by category if provided
    if params[:category].present?
      @gear_items = @gear_items.where(category: params[:category])
    end

    # Filter by featured
    if params[:featured] == "true"
      @gear_items = @gear_items.where(featured: true)
    end

    # Filter by price range
    if params[:price_range].present?
      case params[:price_range]
      when "under_100"
        @gear_items = @gear_items.where("price < ?", 100)
      when "100_500"
        @gear_items = @gear_items.where("price >= ? AND price < ?", 100, 500)
      when "500_1000"
        @gear_items = @gear_items.where("price >= ? AND price < ?", 500, 1000)
      when "over_1000"
        @gear_items = @gear_items.where("price >= ?", 1000)
      end
    end

    # Search by name or description
    if params[:search].present?
      @gear_items = @gear_items.where(
        "name LIKE ? OR description LIKE ?",
        "%#{params[:search]}%",
        "%#{params[:search]}%"
      )
    end
  end

  def new
    @gear_item = GearItem.new
  end

  def create
    @gear_item = GearItem.new(gear_item_params)

    if @gear_item.save
      redirect_to admin_gear_items_path, notice: "Gear item was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @gear_item.update(gear_item_params)
      redirect_to admin_gear_items_path, notice: "Gear item was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gear_item.destroy
    redirect_to admin_gear_items_path, notice: "Gear item was successfully deleted.", status: :see_other
  end

  def purge_product_image
    if @gear_item.product_image.attached?
      @gear_item.product_image.purge
      redirect_to edit_admin_gear_item_path(@gear_item), notice: "Product image was successfully removed."
    else
      redirect_to edit_admin_gear_item_path(@gear_item), alert: "No product image to remove."
    end
  end

  private

  def set_gear_item
    @gear_item = GearItem.find(params[:id])
  end

  def gear_item_params
    params.require(:gear_item).permit(
      :name,
      :description,
      :category,
      :price,
      :featured,
      :position,
      :image_url,
      :product_image,
      :affiliate_link
    )
  end
end
