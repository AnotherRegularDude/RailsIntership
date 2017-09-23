module ApplicationHelper
  def paginate(url_attrs)
    curr_page = params[:page] || 1
    locals = {
      curr_page: curr_page.to_i,
      url_attrs: url_attrs
    }

    render partial: 'shared/pagination', locals: locals
  end
end
