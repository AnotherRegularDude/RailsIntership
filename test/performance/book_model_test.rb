require 'test_helper'
require 'rails/performance_test_help'

class BookModelTest < ActionDispatch::PerformanceTest
  def setup
    self.profile_options = { metrics: [:wall_time] }

    params_array = []
    custom_book = { title: 'bench', description: 'bench', author: 'bench' }

    9_999.times do
      params_array << book_params
    end

    Book.create(book_params)
    Book.create(title: 'bench', description: 'bench', author: 'bench')
  end

  test 'create 10_000 books' do
    params_array = []

    10_000.times do
      params_array << book_params
    end

    Book.create(book_params)
  end

  test 'find 9_000 books of 10_000 books' do
    ids = 1..9000
    Book.find(ids.to_a)
  end

  test 'find books with author and title of 10_000 books' do
    Book.select_where(author: 'bench', description: 'bench')
  end

  test 'delete 9_000 boks of 10_000 books' do
    ids = 1..9000
    books = Book.find(ids.to_a)

    books.each { |book| book.delete }
  end

  def book_params
    {
        title: Faker::Book.title,
        description: Faker::Book.genre,
        author: Faker::Book.author
    }
  end
end
