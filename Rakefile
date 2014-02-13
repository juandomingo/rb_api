require 'sinatra/activerecord/rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

task default: :test

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => 'db/test.sqlite3'
)