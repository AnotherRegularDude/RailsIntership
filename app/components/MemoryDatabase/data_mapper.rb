class MemoryDatabase::DataMapper
  def initialize
    @saved_data = {}
    @staged_data = {}
  end
end