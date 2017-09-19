class BooksController < ApplicationController
  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    @book.save
    redirect_to new_book_url
  end

  private

  def book_params
    params.require(:book).permit(:title, :description, :author)
  end
end
