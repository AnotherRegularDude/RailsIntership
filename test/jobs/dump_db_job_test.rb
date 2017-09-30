require 'test_helper'

class DumpDbJobTest < ActiveJob::TestCase
  test 'db properly dumped, file created' do
    create_books(100)
    DumpDbJob.perform_now

    assert File.exist?(DbManager::DUMP_PATH)
    assert_equal 2, length_of_tables.size
    assert_equal PublishingHouse.managed_data.size, length_of_tables[0]
    assert_equal Book.managed_data.size, length_of_tables[1]
  end

  test 'db properly loaded' do
    create_books(100)
    ph_managed_data = PublishingHouse.managed_data
    bk_managed_data = Book.managed_data

    DumpDbJob.perform_now
    DbManager.instance.load_dump

    assert_equal ph_managed_data, PublishingHouse.managed_data
    assert_equal bk_managed_data, Book.managed_data
  end

  private

  def length_of_tables
    File.open(DbManager::DUMP_PATH) { |f| f.read[0...8].unpack('L*') }
  end
end
