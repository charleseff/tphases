shared_context "setup mode specs" do

  #before(:suite) do
  before(:all) do
    dbconfig             = YAML::load(File.open(LIB_ROOT + '/spec/fixtures/database.yml'))
    dbconfig['database'] = LIB_ROOT + '/' + dbconfig['database']
    FileUtils.mkdir_p LIB_ROOT + '/temp'
    ActiveRecord::Base.establish_connection(dbconfig)
    ActiveRecord::Base.connection.execute("CREATE TABLE IF NOT EXISTS posts (t1 string)")
    ActiveRecord::Base.connection.execute("DELETE FROM posts")
  end

  let(:read_sql) { 'select * from posts' }
  let(:write_sql) { "insert into posts values ('foobaz')" }

end