class PublishingHouse < BaseModel
  PACK_STRING = 'A36A40'.freeze

  class << self
    def indexed_fields
      %i[name]
    end

    def data_size
      76
    end

    def from_mem(raw_data)
      data = raw_data.unpack(PACK_STRING)
      return if data[0].blank?

      new(id: data[0], name: data[1])
    end
  end

  define_attribute_methods :name
  attr_reader :name

  has_many :books

  def name=(value)
    name_will_change! unless @name == value || @name.nil?

    @name = value
  end

  def attributes
    { id: @id, name: @name }
  end

  def attributes=(value)
    self.id = value[:id] || id
    self.name = value[:name] || name
  end

  validates :name, presence: true, length: { in: 2..40 }

  def to_mem
    [id, name].pack(PACK_STRING)
  end
end
