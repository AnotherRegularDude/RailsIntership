module ApplicationHelper
  def paginate(total_pages, url_attrs)
    curr_page = params[:page] || 1
    locals = {
      curr_page: curr_page.to_i,
      total_pages: total_pages,
      url_attrs: url_attrs
    }

    render partial: 'shared/pagination', locals: locals
  end
end
