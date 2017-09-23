# Base Model With DB Logic
class BaseModel
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

    def belongs_to(class_references)
      class_references.each do |class_reference|
        define_method(class_reference.name.underscore) do
          foreign_key_name = "@#{class_reference.name.foreign_key}"
          class_reference.find(instance_variable_get(foreign_key_name))
        end
      end
    end

    def has_many(class_references)
      foreign_key_name = name.foreign_key.to_sym

      class_references.each do |class_reference|
        define_method(class_reference.name.tableize) do
          ids = class_reference.managed_index[foreign_key_name][id]

          class_reference.find(ids)
        end
      end

      define_method(:delete_cascade) do
        class_references.each do |class_reference|
          ids = class_reference.managed_index[foreign_key_name][id]
          instances = class_reference.find(ids)

          instances.each(&:delete)
          class_reference.managed_index[foreign_key_name].delete(id)
        end
      end

      before_delete :delete_cascade
    end

    def create(params)
      if params.instance_of? Array
        params.each do |instance_params|
          new(instance_params).save
        end
      else
        instance = new(params)
        instance.save

        instance
      end
    end

    def find(find_value)
      if find_value.instance_of? Array
        selected = find_value.map do |id|
          { **managed_data[id], id: id } if managed_data[id].present?
        end

        selected.select(&:present?)
        Paginator.new(selected.map { |item| new(item) })
      else
        selected = managed_data[find_value]
        new(**selected, id: find_value) if selected.present?
      end
    end

    def find_by_id!(id)
      record = find(id)
      raise ActiveRecord::RecordNotFound if record.nil?

      record
    end

    def select_where(query)
      query_copy = query.dup
      index_result = index_where(query_copy) || managed_data.keys

      selected_items = index_result.map do |id|
        selected = true
        value = managed_data[id]
        query_copy.each { |k, v| selected = false if value[k] != v }

        { **value, id: id } if selected
      end

      selected_items.select(&:present?)
      Paginator.new(selected_items.map { |item| new(item) })
    end

    def index_where(query)
      indexed_query = query.slice(*indexed_fields)
      return nil if indexed_query.size.zero?

      min_key, min_value = indexed_query.min_by do |k, v|
        managed_index[k][v] = [] if managed_index[k][v].nil?
        managed_index[k][v].length
      end
      query.delete(min_key)
      managed_index[min_key][min_value]
    end

    def all
      data_to_paginate = managed_data.map do |key, value|
        new(**value, id: key)
      end
      Paginator.new(data_to_paginate)
    end
  end

  define_attribute_methods :id
  define_model_callbacks :delete
  attr_reader :id

  def id=(value)
    id_will_change! unless @id == value || @id.nil?

    @id = value
  end

  def attributes
    {}
  end

  def attributes=(value)
  end

  def persisted?
    id.present?
  end

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
    return false if id.nil? || !valid?

    self.attributes = attributes if attributes.present?
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

  protected

  def insert_into_index(field_name)
    self.class.managed_index[field_name] ||= {}
    field_index = self.class.managed_index[field_name]

    field_index[attributes[field_name]] ||= []
    field_index[attributes[field_name]] << id
  end

  def update_at_index(field_name)
    return unless send("#{field_name}_changed?")
    field_index = self.class.managed_index[field_name]
    prev_value, new_value = changes[field_name]

    field_index[new_value] ||= []
    field_index[prev_value].delete(id)
    field_index[new_value] << id
  end

  def delete_at_index(field_name)
    field_index = self.class.managed_index[field_name]
    restore_attributes

    field_index[attributes[field_name]].delete(id)
  end
end
