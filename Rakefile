require_relative "app"

namespace :db do
  desc "run migrations"
  task :migrate do
    require_relative "config/database.rb"
    ActiveRecord::Migrator.migrate("db/migrations", nil)
  end
end
