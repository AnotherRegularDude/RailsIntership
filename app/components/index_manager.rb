class IndexManager
  include Singleton

  def [](table_name)
    @indexes[table_name]
  end

  def []=(table_name, index)
    @indexes[table_name] = index
  end

  def initialize
    @indexes = Hash.new({})
  end

end
