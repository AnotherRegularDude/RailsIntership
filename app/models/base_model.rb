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

    def find(find_value)
      if find_value.instance_of? Array
        selected = find_value.map { |id| managed_data[id] }
        selected.each_with_index.map do |item, i|
          new(**item, id: i)
        end
      else
        selected = managed_data[find_value]
        if selected.present?
          new(**selected, id: find_value)
        else
          nil
        end
      end
    end

    def find_by_id!(id)
      record = find(Integer(id))
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

  def save
    @id = self.class.managed_data.length

    self.class.managed_data << attributes
  end
end
