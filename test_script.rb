require 'pry'
require 'active_record'
dbconfig = YAML::load(File.open('spec/fixtures/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
binding.pry
#puts ActiveRecord::Base.connection.select_all('show tables')
