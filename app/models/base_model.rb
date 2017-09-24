# Base Model With DB Logic
class BaseModel
  include Indexable
  include Relational
  include TableClassConcern

  include ActiveModel::Dirty
  include ActiveModel::Model

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

    def indexed_fields
      []
    end
  end

  attr_reader :id

  def attributes
    {}
  end

  def attributes=(value)
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

  def save
    return false unless valid?

    self.id = object_id
    self.class.managed_data[id] = attributes

    self.class.indexed_fields.each do |field_name|
      insert_into_index(field_name)
    end

    changes_applied
  end

  def update(attributes = [])
    self.attributes = attributes if attributes.present?
    return false unless can_update?

    self.class.managed_data[id] = self.attributes
    self.class.indexed_fields.each { |field_name| update_at_index(field_name) }

    changes_applied
    true
  end

  def delete
    return false if id.nil?

    run_callbacks :delete do
      self.class.indexed_fields.each { |field| delete_at_index(field) }
      self.class.managed_data.delete(id)
      @id = nil
    end

    true
  end

  private

  def can_update?
    return true if id.present? && valid?

    restore_attributes
    false
  end
end
