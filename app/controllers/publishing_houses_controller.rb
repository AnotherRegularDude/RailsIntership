class PublishingHousesController < ApplicationController
  before_action :find_or_404, except: %i[index new create]

  def index
    paginated = PublishingHouse.all

    @publishing_houses = paginated.page(params[:page]) || []
    @total_pages = paginated.total_pages
  end

  def show; end

  def edit; end

  def new
    @publishing_house = PublishingHouse.new
  end

  def create
    @publishing_house = PublishingHouse.new(publishing_house_params)
    @publishing_house.save

    redirect_to new_publishing_house_url
  end

  def update
    @publishing_house.update(publishing_house_params)

    redirect_to edit_publishing_house_url(id: @publishing_house.id)
  end

  def destroy
    @publishing_house.delete

    redirect_to publishing_houses_url
  end

  private

  def publishing_house_params
    params.require(:publishing_house).permit(:name)
  end

  def find_or_404
    @publishing_house = PublishingHouse.find_by_id!(params[:id])
  end
end
