class GearItemsController < ApplicationController
  def index
    @categories = GearItem.pluck(:category).uniq.compact.sort
    @selected_category = params[:category]

    if @selected_category.present?
      @gear_items = GearItem.by_category(@selected_category)
    else
      @gear_items = GearItem.ordered
    end

    @featured_gear = GearItem.featured
    @tech_gear = GearItem.tech.limit(6)
    @fitness_gear = GearItem.fitness.limit(6)
    @everyday_gear = GearItem.everyday.limit(6)
  end
end
