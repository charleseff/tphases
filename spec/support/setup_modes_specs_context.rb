shared_context "setup mode specs" do

  before do
    dbconfig             = YAML::load(File.open(LIB_ROOT + '/spec/fixtures/database.yml'))
    dbconfig['database'] = LIB_ROOT + '/' + dbconfig['database']
    ActiveRecord::Base.establish_connection(dbconfig)
  end

  let(:read_sql) { 'select * from posts' }
  let(:write_sql) { "insert into posts values ('foobaz')" }

end