# Manage Database Records via this singleton.
class MemoryDatabase::Manager
  class << self
    attr_accessor :instance

    def create
      if self.class.instance.present?
        raise ManagerSingletonError, 'Only Singleton'
      end

      @instance = self.new
    end
  end

  def initialize
    @data_mappers = {}
  end

  def [](table_name)
    return @data_mappers[table_name] if @data_mappers.key? table_name

    @data_mappers[table_name] = DataMapper.new
    @data_mappers[table_name]
  end
end