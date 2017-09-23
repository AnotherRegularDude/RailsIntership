class IndexManager
  include Singleton

  def [](table_name)
    @indexes[table_name]
  end

  def []=(table_name, index)
    @indexes[table_name] = index
  end

  # Here's if we use Hash.new({}) instead {},
  # we will see the following behavior:
  # Default return value is new Hash, but for books and for publishing_houses
  # there is same Hash:
  # IndexManager.instance['books'] == IndexManager.instance['publishing_houses']!
  def initialize
    @indexes = {}
  end

end
