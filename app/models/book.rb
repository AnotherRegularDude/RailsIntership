class Book < BaseModel
  class << self
    def indexed_fields
      [:title, :author, :publishing_house_id]
    end
  end

  define_attribute_methods :title, :description, :author, :publishing_house_id
  attr_reader :title, :description, :author, :publishing_house_id


  belongs_to [PublishingHouse]

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

  def publishing_house_id=(value)
    unless @publishing_house_id == value || @publishing_house_id.nil?
      publishing_house_id_will_change!
    end

    @publishing_house_id = value
  end

  def attributes
    {
      title: @title,
      description: @description,
      author: @author,
      publishing_house_id: @publishing_house_id
    }
  end

  def attributes=(value)
    self.id = value[:id] || id
    self.title = value[:title] || title
    self.description = value[:description] || description
    self.author = value[:author] || author
    self.publishing_house_id = value[:publishing_house_id] || publishing_house_id
  end

  validates :title, :description, :author, :publishing_house_id, presence: true
end
