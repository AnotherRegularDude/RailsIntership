# It's like a table manager
class MemoryDatabase::DataMapper
  def initialize
    @saved_data = []
  end

  def [](index)
    @saved_data[index]
  end

  def insert_one(data_in_hash)
    return 0 if data_in_hash == {}

    data_in_hash[:id] = SecureRandom.hex
    @saved_data << data_in_hash

    data_in_hash
  end

  def insert_many(array_of_data)
    array_of_data.each { |item| insert_one(item) }
  end

  def find(find_query)
    find_key = find_query.keys[0]
    find_value = find_query[find_key]

    @saved_data.select { |item| item[find_key] == find_value }
  end

  def update_at(index, attributes)
  end

  def find_one(find_query)
    find(find_query).first
  end
end
