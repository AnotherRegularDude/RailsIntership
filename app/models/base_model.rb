class BaseModel
  include ActiveModel::Model
  include ActiveModel::Conversion

  class << self
    def table_name
      name.tableize
    end

    def data_manager
      MemoryDatabase::Manager.instance[table_name]
    end

    def find(find_query)
      results = data_manager.find(find_query)
      results.each { |item| new(item) }
    end

    def find_one(find_query)
      result = data_manager.find_one(find_query)
      return nil if result.nil?

      new(result)
    end
  end

  def save
    self.class.data_manager.insert_one(attributes)
  end
end
