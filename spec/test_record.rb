class User < CassandraRecord::Base
  # Default is :Users, but you can change it
  column_family :Users
  attribute :first_name 
  attribute :last_name

  validates_presence_of :last_name
  
  before_save :set_name_to_john
  
  def set_name_to_john
    self.first_name = 'John'
  end

end
