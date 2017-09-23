require 'test_helper'

class PublishingHouseTest < ActiveSupport::TestCase
  test 'publishing house removed, belonged books removed' do
    publishing_house = create_publishing_house
    id = publishing_house.id
    create_books { |params| params[:publishing_house_id] = id }
    create_books
    books_count = Book.all.length

    publishing_house.delete

    assert_equal books_count - 10, Book.all.length
    assert_equal 2, PublishingHouse.all.length
    assert_nil Book.managed_index[:publishing_house_id][id]
  end

  private

  def create_publishing_house
    PublishingHouse.create(publishing_house_params)
  end
end
