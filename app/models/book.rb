class Book < BaseModel
  def attributes
    { title: @title, description: @description, author: @author }
  end

  attr_accessor :id, :title, :description, :author
end
