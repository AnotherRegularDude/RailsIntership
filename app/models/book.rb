class Book < BaseModel
  class << self
    def where_keys_to_select
      [:title, :description, :author]
    end
  end

  def attributes
    { title: @title, description: @description, author: @author }
  end

  def attributes=(value)
    @title = value[:title] || @title
    @description = value[:description] || @description
    @author = value[:author] || @author
  end

  attr_accessor :title, :description, :author
end
