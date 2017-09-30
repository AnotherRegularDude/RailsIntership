class DumpDbJob < ApplicationJob
  RUN_EVERY = 5.minutes

  queue_as :default

  def perform
    PublishingHouse.vacuum_optimize
    Book.vacuum_optimize
    DbManager.instance.dump_to_file

    self.class.set(wait: RUN_EVERY).perform_later
  end
end
