require 'test_helper'

class BookTest < ActiveSupport::TestCase
  test 'create book' do
    book = new_book
    book.save

    assert_equal book.id, Book.managed_index[:id].keys.first
    assert_equal 1, Book.all.size
  end

  test 'create few books' do
    create_books

    assert_equal 10, Book.all.size
  end

  test 'find book_by id' do
    create_books
    existed_id = Book.managed_index[:id].keys[0]
    not_existed_id = 'not_existed'

    existed_book = Book.find existed_id
    not_existed_book = Book.find not_existed_id

    assert_not_nil existed_book
    assert_nil not_existed_book
  end

  test 'find books_by ids' do
    create_books
    ids = Book.managed_index[:id].keys[1..3]

    books = Book.find(ids)
    assert_equal ids.length, books.length
  end

  test 'update book' do
    book = new_book
    book.save

    title = 'New book'
    id_before_update = book.id
    book.update(title: title)

    assert_not_nil book.description
    assert_not_nil book.author

    assert_equal id_before_update, book.id
    assert_equal title, book.title
  end

  test 'update book through attrs' do
    book = new_book
    book.save

    title = 'New title'

    book.title = title
    id_before_update = book.id
    book.update

    assert_not_nil book.description
    assert_not_nil book.author

    assert_equal id_before_update, book.id
    assert_equal title, book.title
  end

  test 'delete book' do
    create_books
    id = Book.managed_index[:id].keys[0]

    book = Book.find(id)
    book.delete

    assert_nil book.id
    assert_equal false, book.delete
  end

  test 'select one book with title' do
    create_books
    id = Book.managed_index[:id].keys[0]

    book = Book.find(id)
    where_book, = Book.select_where(title: book.title)

    assert_equal book.id, where_book.id
  end

  test 'select one book with author, description' do
    create_books
    id = Book.managed_index[:id].keys[0]

    book = Book.find(id)
    select_params = { description: book.description, author: book.author }
    where_book, = Book.select_where(select_params)

    assert_equal book.id, where_book.id
  end

  test 'create book with empty data' do
    bad_book = Book.new

    assert_not bad_book.save
  end

  test 'play with pagination' do
    create_books 1000

    paginated_books = Book.all.page
    nil_paginated = Book.all.page 1000

    assert_equal 20, paginated_books.length
    assert_nil nil_paginated
  end

  test 'insert book, check fields indexed' do
    book = new_book
    book.save

    assert_equal book.id, Book.managed_index[:title][book.title][0]
    assert_equal book.id, Book.managed_index[:author][book.author][0]
  end

  test 'update book, check fields indexed' do
    create_books
    book = Book.all[1]
    new_title = 'My title'

    book.update(title: new_title)

    assert Book.managed_index[:title][book.title].include? book.id
    assert Book.managed_index[:author][book.author].include? book.id
  end

  test 'delete book, check indexes deleted' do
    create_books
    book = Book.all[1]
    id = book.id

    book.delete

    assert_not Book.managed_index[:title][book.title].include? id
    assert_not Book.managed_index[:author][book.author].include? id
  end

  test 'delete book with changed data, check indexed' do
    create_books
    book = Book.all[1]
    id = book.id
    author = book.author

    book.author = 'Another Author'
    book.delete

    assert_not Book.managed_index[:title][book.title].include? id
    assert_not Book.managed_index[:author][author].include? id
  end

  test 'get ids from indexed fields' do
    create_books { |item| item[:title] = 'MyTitle' }
    create_books

    with_index_books = Book.index_where(title: 'MyTitle')

    assert_equal 10, with_index_books.length
  end

  test 'get not existed field in index' do
    create_books
    title = 'MyNotExistedTitle'

    with_index_books = Book.index_where(title: title)

    assert_empty with_index_books
  end

  test 'remove book from publishing house' do
    create_books
    publishing_house = PublishingHouse.all.first
    old_length = publishing_house.books.length

    publishing_house.books[0].delete

    assert_equal old_length - 1, publishing_house.books.length
  end

  test 'update book, change publishing house' do
    create_books
    old_publishing = PublishingHouse.all.first
    new_publishing = PublishingHouse.create(publishing_house_params)
    old_length = old_publishing.books.length

    changed_book = old_publishing.books[0]
    changed_book.update(publishing_house_id: new_publishing.id)

    assert_equal 1, new_publishing.books.length
    assert_equal old_length - 1, old_publishing.books.length
  end

  test 'book have right publishing house id' do
    create_books
    publishing_house = PublishingHouse.all.first
    book = Book.all.first

    assert_equal book.publishing_house.id, publishing_house.id
  end

  test 'right pages count' do
    create_books 115
    total_pages = Book.all.total_pages

    assert_equal 6, total_pages
  end

  test 'create large number of books, ensure all added' do
    create_books 10_000

    assert_equal 10_000 * Book.data_size, Book.managed_data.size
  end

  private

  def new_book
    publishing_house = PublishingHouse.create(publishing_house_params)

    Book.new(**book_params, publishing_house_id: publishing_house.id)
  end
end
