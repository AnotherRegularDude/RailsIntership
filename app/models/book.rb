class Book < BaseModel
  def attributes
    { title: @title, description: @description, author: @author }
  end

  attr_accessor :title, :description, :author
end
