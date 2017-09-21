# Base Model With DB Logic
class BaseModel
  include ActiveModel::Model
  include ActiveModel::Conversion

  class << self
    def table_name
      name.tableize
    end

    def where_keys_to_select
      {}
    end

    def managed_data
      DbManager.instance[table_name]
    end

    def create(params)
      if params.instance_of? Array
        params.each do |book_params|
          new(book_params).save
        end
      else
        book = new(params)
        book.save

        book
      end
    end

    def find(find_value)
      if find_value.instance_of? Array
        selected = find_value.map do |id|
          { **managed_data[id], id: id } if managed_data[id].present?
        end

        selected.select(&:present?)
        selected.map { |item| new(item) }
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
      selected_items = managed_data.map do |key, value|
        selected = true
        query.each { |k, v| selected = false if value[k] != v }

        { **value, id: key } if selected
      end

      selected_items.select(&:present?)
      selected_items.map { |item| new(item) }
    end

    def all
      managed_data.map { |key, value| new(**value, id: key) }
    end
  end

  attr_accessor :id

  def attributes
    {}
  end

  def attributes=(value)
  end

  def save
    @id = object_id

    self.class.managed_data[@id] = attributes
  end

  def update(attributes = [])
    return false if id.nil?

    self.attributes = attributes if attributes.present?
    self.class.managed_data[@id] = self.attributes

    true
  end

  def delete
    return false if id.nil?

    self.class.managed_data.delete(id)
    @id = nil

    true
  end
end
