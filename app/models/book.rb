class Book < BaseModel
  define_attribute_methods :title, :description, :author
  attr_reader :title, :description, :author

  def title=(value)
    title_will_change! unless @title == value || @title.nil?

    @title = value
  end

  def description=(value)
    description_will_change! unless @description == value || @description.nil?

    @description = value
  end

  def author=(value)
    author_will_change! unless @author == value || @author.nil?

    @author = value
  end

  def attributes
    { title: @title, description: @description, author: @author }
  end

  def attributes=(value)
    self.id = value[:id] || id
    self.title = value[:title] || title
    self.description = value[:description] || description
    self.author = value[:author] || author
  end

  def indexed_fields
    [:title, :author]
  end

  validates :title, :description, :author, presence: true
end
