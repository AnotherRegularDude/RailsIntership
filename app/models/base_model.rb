# Base Model With DB Logic
class BaseModel
  include Indexable
  include Relational
  include TableClassConcern
  include DataPlaceOptimizable

  include ActiveModel::Dirty
  include ActiveModel::Model

  attr_reader :id

  class << self
    def table_name
      name.tableize
    end

    def managed_data
      DbManager.instance[table_name]
    end

    def managed_index
      IndexManager.instance[table_name]
    end

    def data_position(id)
      return if managed_index[:id][id].nil?

      shift = managed_index[:id][id]
      data_begin = shift * data_size
      data_end = data_begin + data_size

      [data_begin, data_end]
    end

    def data_position_by_shift(shift)
      return if shift * data_size >= managed_data.size

      data_begin = shift * data_size
      data_end = data_begin + data_size

      [data_begin, data_end]
    end

    def managed_data_by_shift(shift)
      from, to = data_position_by_shift(shift)

      managed_data[from...to]
    end
  end

  def data_position
    self.class.data_position(id)
  end

  def persisted?
    id.present?
  end

  def id=(value)
    id_will_change! unless @id == value || @id.nil?

    @id = value
  end

  define_attribute_methods :id
  define_model_callbacks :delete

  validates :id, presence: true, length: { is: 36 }

  def save
    self.id = SecureRandom.uuid
    return false unless can_create?

    self.class.managed_data << to_mem
    index_data

    changes_applied
    true
  end

  def update(attributes = [])
    self.attributes = attributes if attributes.present?
    return false unless can_update?
    from, to = data_position

    self.class.managed_data[from...to] = to_mem
    self.class.indexed_fields.each { |field_name| update_at_index(field_name) }

    changes_applied
    true
  end

  def delete
    return false if id.nil?
    from, to = data_position

    run_callbacks :delete do
      delete_id_at_index
      self.class.indexed_fields.each { |field| delete_at_index(field) }
      self.class.managed_data[from...to] = ' ' * self.class.data_size
      @id = nil
    end

    true
  end

  def index_data(shift = nil)
    insert_id_into_index(shift)
    self.class.indexed_fields.each do |field_name|
      insert_into_index(field_name)
    end
  end

  delegate :[], to: :attributes

  private

  def can_create?
    return true if valid?

    @id = nil
    false
  end

  def can_update?
    return true if valid?

    restore_attributes
    false
  end
end
