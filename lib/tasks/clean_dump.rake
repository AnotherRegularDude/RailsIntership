namespace :db do
  desc "Remove database's dump file from tmp"
  task clean_dump: :environment do
    File.open(DbManager::DUMP_PATH, 'wb+')
  end
end
