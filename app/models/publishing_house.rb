class PublishingHouse < BaseModel
  class << self
    def indexed_fields
      [:name]
    end
  end

  define_attribute_methods :name
  attr_reader :name

  has_many [Book]

  def name=(value)
    name_will_change! unless @name == value || @name.nil?

    @name = value
  end

  def attributes
    { name: @name }
  end

  def attributes=(value)
    self.id = value[:id] || id
    self.name = value[:name] || name
  end
  
  validates :name, presence: true
end
