# Base Model With DB Logic
class BaseModel
  include ActiveModel::Model
  include ActiveModel::Conversion

  class << self
    def table_name
      name.tableize
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
        selected = find_value.map { |id| managed_data[id] }
        selected.delete_if(&:nil?)
        selected.each_with_index.map do |item, i|
          new(**item, id: i)
        end
      else
        selected = managed_data[find_value]
        new(**selected, id: find_value) if selected.present?
      end
    end

    def find_by_id(id)
      find(Integer(id))
    end

    def find_by_id!(id)
      record = find_by_id(id)
      raise ActiveRecord::RecordNotFound if record.nil?

      record
    end

    def all
      managed_data.each_with_index.map do |item, i|
        new(**item, id: i)
      end
    end
  end

  attr_accessor :id

  def attributes
    {}
  end

  def attributes=(value)
  end

  def save
    @id = self.class.managed_data.length

    self.class.managed_data << attributes
  end

  def update(attributes = [])
    return false if id.nil?

    self.attributes = attributes if attributes.present?
    self.class.managed_data[@id] = self.attributes

    true
  end

  def delete
    return false if id.nil?

    self.class.managed_data[id] = nil
    @id = nil

    true
  end
end
