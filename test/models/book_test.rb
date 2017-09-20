require 'test_helper'

class BookTest < ActiveSupport::TestCase
  setup do
    DbManager.instance[Book.table_name] = []
  end

  test 'create book' do
    book = new_book
    book.save

    assert_equal 0, book.id
    assert_equal 1, Book.all.length
  end

  test 'create few books' do
    create_books

    assert_equal 10, Book.all.length
  end

  test 'find book_by id' do
    create_books

    existed_book = Book.find 5
    not_existed_book = Book.find 100_00

    assert_not_nil existed_book
    assert_equal 5, existed_book.id

    assert_nil not_existed_book
  end

  test 'find books_by ids' do
    create_books
    ids = [1, 2, 3, 4, 100]

    books = Book.find(ids)
    assert_equal ids.length - 1, books.length
  end

  test 'update book' do
    book = new_book
    book.save

    title = 'New book'
    book.update(title: title)

    assert_not_nil book.description
    assert_not_nil book.author

    assert_equal 0, book.id
    assert_equal title, book.title

    assert_equal title, Book.managed_data[0][:title]
  end

  test 'update book through attrs' do
    book = new_book
    book.save

    title = 'New title'

    book.title = title
    book.update

    assert_not_nil book.description
    assert_not_nil book.author

    assert_equal 0, book.id
    assert_equal title, book.title

    assert_equal title, Book.managed_data[0][:title]
  end

  test 'delete book' do
    create_books
    id = 5

    book = Book.find(id)
    book.delete

    assert_nil book.id
    assert_equal false, book.delete
    assert_nil Book.managed_data[id]
  end

  test 'select one book with title' do
    create_books
    id = 5

    book = Book.find(id)
    where_book, _ = Book.select_where(title: book.title)

    assert_equal book.id, where_book.id
  end

  test 'select one book with author, description' do
    create_books
    id = 5

    book = Book.find(id)
    select_params = { description: book.description, author: book.author }
    where_book, _ = Book.select_where(select_params)

    assert_equal book.id, where_book.id
  end

  private

  def book_params
    {
        title: Faker::Book.title,
        description: Faker::Book.genre,
        author: Faker::Book.author
    }
  end

  def new_book
    Book.new(book_params)
  end

  def create_books(number = 10)
    params_array = []
    number.times do
      params_array << book_params
    end

    Book.create(params_array)
  end
end
