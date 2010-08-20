require 'rubygems'
require 'active_model'
require 'hash'
require 'set'
require 'cassandra/0.7'
require 'yaml'

module CassandraRecord
  class Base
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml
    include ActiveModel::Dirty
    extend ActiveModel::Callbacks
    define_model_callbacks :create, :save, :delete, :update

    self.include_root_in_json = false

    module ConnectionManagement
      
      attr_reader :connection
      
      def establish_connection(args)
        host = args[:host]||'localhost'
        port = args[:port].to_s||'9160'
        @connection = connection_class.new(args[:keyspace], host+':'+port )
      end

      def connection_class
        Cassandra
      end

    end
    extend ConnectionManagement


    module Attributes

      def attribute(name)
        dirty_attr_accessor(name)
        @attribute_names ||= Set.new
        @attribute_names << name.to_s
        define_attribute_methods(@attribute_names.to_a)
      end

      def attribute_names
        @attribute_names.to_a
      end

      def dirty_attr_accessor(name)
        attr_reader name
        define_method(name.to_s+'=') do |value|
          eval(name.to_s+'_will_change!') unless value == instance_variable_get("@#{name}")
          instance_variable_set("@#{name}", value)
        end
      end

    end
    extend Attributes

    module ColumnFamilyAttribute

      def column_family(name)
        @column_family = name
      end

      def column_family_name
        @column_family || self.name.pluralize.to_sym
      end

    end
    extend ColumnFamilyAttribute

    module BasicOperations

      def attributes
        attr = {}
        self.class.attribute_names.each do |name|
          attr[name] = self[name]
        end
        attr
      end

      def [](column)
        column_instance = '@'+column
        if instance_variables.include?(column_instance) ||
            instance_variables.include?(column_instance.to_sym)
          instance_variable_get(column_instance) 
        else
          nil
        end 
      end

      def []=(column, value)      
        if self.class.attribute_names.include?(column) 
          eval(column.to_s+'_will_change!') unless value == instance_variable_get("@#{column}")
          instance_variable_set('@'+column, value) 
        else
          value
        end
      end

      def persistend?
        true
      end
      
    end
    include BasicOperations

    module CassandraOperations
      def save
        _run_save_callbacks do
          
        end
      end

      def delete
        _run_delete_callbacks do
          
        end
      end

      def create(attributes = nil)
        _run_create_callbacks do
        end
      end

    end
    include CassandraOperations

  end

end
