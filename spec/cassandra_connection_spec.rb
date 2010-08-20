require File.dirname(__FILE__) + '/spec_helper.rb'
require 'cassandra_record'
require 'cassandra_mock'

describe CassandraRecord::Base, 'should connect to Cassandra db' do 
  before(:each) do
    CassandraRecord::Base.stub!(:connection_class).and_return CassandraMock
  end

  it "should esteblish connection" do
    CassandraRecord::Base.establish_connection(:kepsyace => 'NewKeyspace', :host => 'localhost', :port => 9160)
    CassandraRecord::Base.connection.class.should == CassandraMock
  end

end
