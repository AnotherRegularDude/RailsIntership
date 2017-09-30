
# Manage Database Records via this singleton.
class DbManager
  include Singleton

  DUMP_PATH = Rails.root.join('tmp', 'dumped.db').freeze
  DUMPED_TABLES = [PublishingHouse.table_name, Book.table_name].freeze

  # Here's if we use Hash.new({}) instead {},
  # we will see the following behavior:
  # Default return value is new Hash, but for books and for publishing_houses
  # there is same Hash:
  # DbManager.instance['books'] == DbManager.instance['publishing_houses']!
  def initialize
    @data_mappers = Hash.new { |hash, table_name| hash[table_name] = '' }
  end

  def dump_to_file
    packed_arr = []
    DUMPED_TABLES.each { |key| packed_arr << @data_mappers[key].size }

    File.open(DUMP_PATH, 'wb+') do |file|
      file.write(packed_arr.pack('L*'))
      DUMPED_TABLES.each { |key| file.write(@data_mappers[key]) }
    end
  end

  def load_dump
    return unless File.exist? DUMP_PATH

    File.open(DUMP_PATH) do |file|
      tables_length = file.read(DUMPED_TABLES.size * 4).unpack('L*')

      DUMPED_TABLES.each_with_index do |key, index|
        @data_mappers[key] = file.read(tables_length[index])
      end
    end
  end

  delegate :[], :[]=, to: :@data_mappers
end
