# For working with ActiveModel pagination via BaseModel.
class Paginator < Delegator
  attr_accessor :per_page

  def __getobj__
    @delegate_dc_obj
  end

  def __setobj__(obj)
    @delegate_dc_obj = obj
  end

  def initialize(arr_to_paginate, per_page = 20)
    @delegate_dc_obj = arr_to_paginate
    self.per_page = per_page
  end

  def page(page_num = nil)
    page_num ||= 1
    page_num = Integer(page_num)
    from_value = (page_num - 1) * per_page
    to_value = page_num * per_page - 1

    @delegate_dc_obj[from_value..to_value]
  end

end
