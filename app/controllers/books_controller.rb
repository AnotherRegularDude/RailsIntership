class BooksController < ApplicationController
  before_action :find_publishing_house_or_404
  before_action :find_book_id_or_404, except: %i[index new create]

  def index
    paginated = @publishing_house.books

    @books = paginated.page(params[:page]) || []
    @total_pages = paginated.total_pages
  end

  def show; end

  def edit; end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    @book.publishing_house_id = @publishing_house.id

    @book.save
    redirect_to new_publishing_house_book_url @publishing_house
  end

  def update
    @book.update(book_params)

    redirect_to edit_publishing_house_book_url(@publishing_house, @book)
  end

  def destroy
    @book.delete

    redirect_params = {
      publishing_house_id: @publishing_house.id
    }
    redirect_to publishing_house_books_url redirect_params
  end

  private

  def find_publishing_house_or_404
    ph_id = params[:publishing_house_id]
    @publishing_house = PublishingHouse.find_by_id!(ph_id)
  end

  def find_book_id_or_404
    @book = Book.find_by_id!(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :description, :author)
  end
end
