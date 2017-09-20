# Manage Database Records via this singleton.
class DbManager
  include Singleton

  def initialize
    @data_mappers = Hash.new([])
  end

  def [](table_name)
    @data_mappers[table_name]
  end

  def []=(table_name, value)
    @data_mappers[table_name] = value
  end
end
