class BooksController < ApplicationController
  before_action :find_or_404, only: [:show]

  def index
    @books = Book.all
  end

  def show
  end

  def edit
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    @book.save
    redirect_to new_book_url
  end

  private

  def find_or_404
    @book = Book.find_by_id!(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :description, :author)
  end
end
