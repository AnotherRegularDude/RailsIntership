class Book < BaseModel
  PACK_STRING = 'A36A50A50A50A36'.freeze

  class << self
    def indexed_fields
      %i[title author publishing_house_id]
    end

    def data_size
      222
    end

    def from_mem(raw_data)
      data = raw_data.unpack(PACK_STRING)
      return if data[0].blank?

      attributes = {
        id: data[0],
        title: data[1],
        description: data[2],
        author: data[3],
        publishing_house_id: data[4]
      }

      new(attributes)
    end
  end

  define_attribute_methods :title, :description, :author, :publishing_house_id
  attr_reader :title, :description, :author, :publishing_house_id

  belongs_to :publishing_house

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
      id: @id,
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
    self.publishing_house_id = (
      value[:publishing_house_id] || publishing_house_id)
  end

  validates :title, :description, :author, :publishing_house_id, presence: true
  validates :publishing_house_id, length: { is: 36 }
  validates :title, :description, :author, length: { maximum: 50 }

  def to_mem
    [id, title, description, author, publishing_house_id]
      .pack(PACK_STRING)
  end
end
