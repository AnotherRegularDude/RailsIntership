# Manage Database Records via this singleton.
class MemoryDatabase::Manager
  include Singleton

  def initialize
    @data_mappers = {}
  end

  def [](table_name)
    return @data_mappers[table_name] if @data_mappers.key? table_name

    @data_mappers[table_name] = DataMapper.new
    @data_mappers[table_name]
  end
end
