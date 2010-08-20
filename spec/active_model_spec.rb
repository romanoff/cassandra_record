require File.dirname(__FILE__) + '/spec_helper.rb'
require 'cassandra_record'
require 'test_record'

describe CassandraRecord::Base, 'should have ActiveModel behavior' do
  
  let(:user) { User.new }

  it "should access attributes through []" do
    user.first_name = 'Evan'
    user['first_name'].should == 'Evan'
    user['last_name'] = 'Weaver'
    user.last_name.should == 'Weaver'
  end

  it "should validate last_name" do
    user.first_name = 'Evan'
    user.should_not be_valid
    user.errors[:last_name].should_not be_nil
  end

  it "should have no errors if validation passes" do
    user.last_name = 'Weaver'
    user.should be_valid
  end

  it "should be able to read attributes" do
    user.first_name.should be_nil
    user.first_name = 'Evan'
    user.first_name.should == 'Evan'
  end

  it "should have to_json method" do
    user.to_json.class.should == String
  end

 it "should have to_xml method" do
    user.to_xml.class.should == String
  end

  it "should detect column changes" do
    user.changed?.should == false
    user.first_name_changed?.should == false
    user.first_name = 'Evan'
    user.first_name_changed?.should == true
    user.last_name_changed?.should == false
    user.changed?.should == true
    user.changes['first_name'].should == [nil, 'Evan']
  end

  it "should detect column changes when using []" do
    user['first_name'] = nil
    user.changed?.should == false
    user['first_name'] = 'Evan'
    user.changed?.should == true
  end

  it "should execute callbacks" do 
    user.first_name.should be_nil
    user.save
    user.first_name.should == 'John'
  end

  it "should return attribute names" do
    User.attribute_names.should == ['first_name', 'last_name']
  end

  it "should return column family name"do   
    User.column_family_name.should == :Users
  end

end
