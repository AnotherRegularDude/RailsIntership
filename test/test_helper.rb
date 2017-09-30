require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'faker'

class ActiveSupport::TestCase
  def setup
    DbManager.instance[Book.table_name] = ''
    IndexManager.instance[Book.table_name] = {}

    DbManager.instance[PublishingHouse.table_name] = ''
    IndexManager.instance[PublishingHouse.table_name] = {}
  end

  def publishing_house_params
    { name: Faker::Book.publisher.truncate(40) }
  end

  def book_params
    {
      title: Faker::Book.title.truncate(50),
      description: Faker::Book.genre.truncate(50),
      author: Faker::Book.author.truncate(50)
    }
  end

  def create_books(number = 10)
    params_array = []
    publishing_house = PublishingHouse.create(publishing_house_params)

    number.times do
      params = book_params
      params[:publishing_house_id] = publishing_house.id

      yield params if block_given?
      params_array << params
    end

    Book.create(params_array)
  end
end
