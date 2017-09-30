# Manage Database Records via this singleton.
class DbManager
  include Singleton

  def [](table_name)
    @data_mappers[table_name]
  end

  def []=(table_name, value)
    @data_mappers[table_name] = value
  end

  # Here's if we use Hash.new({}) instead {},
  # we will see the following behavior:
  # Default return value is new Hash, but for books and for publishing_houses
  # there is same Hash:
  # DbManager.instance['books'] == DbManager.instance['publishing_houses']!
  def initialize
    @data_mappers = Hash.new { |hash, table_name| hash[table_name] = '' }
  end
end
