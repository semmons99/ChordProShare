require_relative "app"

desc "run all tasks necessary to get a working environment"
task :setup do
  Rake::Task["db:migrate"].execute
end

namespace :db do
  desc "run migrations"
  task :migrate do
    require_relative "config/database.rb"
    ActiveRecord::Migrator.migrate("db/migrations", nil)
  end
end
