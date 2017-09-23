require 'test_helper'

class PublishingHouseTest < ActiveSupport::TestCase
  test 'publishing house removed, belonged books removed' do
    publishing_house = publishing_house_with_books
    id = publishing_house.id
    create_books
    books_count = Book.all.length

    publishing_house.delete

    assert_equal books_count - 10, Book.all.length
    assert_equal 2, PublishingHouse.all.length
    assert_nil Book.managed_index[:publishing_house_id][id]
  end

  test 'delete publishing house without books' do
    publishing_house = create_publishing_house
    id = publishing_house.id

    publishing_house.delete

    assert_nil publishing_house.id
    assert_nil PublishingHouse.managed_data[id]
  end

  test 'publishing house update with not valid attributes' do
    publishing_house = create_publishing_house

    publishing_house.name = ''

    assert_not publishing_house.update
  end

  test "publishing house's #books return Paginator" do
    publishing_house = publishing_house_with_books

    assert_instance_of Paginator, publishing_house.books
  end

  private

  def create_publishing_house
    PublishingHouse.create(publishing_house_params)
  end

  def publishing_house_with_books(book_num = 10)
    ph = PublishingHouse.create(publishing_house_params)
    create_books(book_num) { |params| params[:publishing_house_id] = ph.id }

    ph
  end
end
