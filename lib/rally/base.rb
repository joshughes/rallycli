require 'fileutils'
module Rally
  class Base

    EDITABLE_TEXT_FIELDS = %w(name description blocked_reason notes)
    EDITABLE_BOOLEAN_FIELDS = %w(ready blocked)
    EDITABLE_OBJECT_RELATIONS = %w(owner)
    EDITABLE_SELECT_FIELDS = {}

    def self.save(name,task)
      unless File.directory?('.rally_cli')
        FileUtils.mkdir_p('.rally_cli')
      end
      File.open(".rally_cli/#{name}.yaml", "w") do |file|
        file.puts YAML::dump(task)
      end
    end

    def self.rally_methods(config=nil)
      if config
        if config.include?(:custom_fields) && config[:custom_fields].include?(self.name.downcase.demodulize.to_sym)
          config[:custom_fields][self.name.downcase.demodulize.to_sym].each do | field_type, fields |
            if  "EDITABLE_SELECT_FIELDS" == "EDITABLE_#{field_type.upcase}"
              fields.each do |field_name, field_value|
                EDITABLE_SELECT_FIELDS[field_name.to_s] = field_value
              end
            end
          end
        end
      end
      EDITABLE_TEXT_FIELDS + EDITABLE_BOOLEAN_FIELDS + EDITABLE_OBJECT_RELATIONS + EDITABLE_SELECT_FIELDS.keys
    end

    def self.load(file_name, rally_cli)
      file = File.open(".rally_cli/#{file_name}.yaml", "r")
      object = YAML.load(file)
      rally_object =  self.find_by_formattedID(object.formattedID, rally_cli)
      object.class.new rally_object, rally_cli.config, object
    end

    def self.find_by_formattedID(formattedID, rally_cli)
      rally_object_name = self.name.split('::').last.downcase
      query = RallyAPI::RallyQuery.new
      query.type         = rally_object_name
      query.query_string = "(FormattedID = #{formattedID})"
      rally_cli.rally_api.find(query).first.read
    end

    def self.build_query(query_objects)
      query_string = "(#{query_objects[0]})"
      if(query_objects.length >= 2)
        query_string += " AND (#{query_objects[1]})"
        query_string.prepend "("
        query_string += ")"
        if(query_objects.length > 2)
          return '(' + query_string + ' AND ' + self.build_query(query_objects[2..(query_objects.length-1)]) + ')'
        else
          return query_string
        end
      else
        return '(' + query_objects.first + ')'
      end
    end

    attr_accessor :rally_object
    attr_reader   :formattedID, :objectID

    def initialize(rally_object, config=nil, object=nil)
      @rally_object   = rally_object
      @formattedID    = rally_object.FormattedID
      @objectID       = rally_object.ObjectID
      define_rally_methods self.class.rally_methods(config)
      load(object) if object
    end

    def to_yaml_properties
      variables = instance_variables
      variables.delete(:@rally_object)
      variables
    end

    def load(object)
      if object
        @formattedID = object.formattedID
        @objectID    = object.objectID
      end
    end

    def update_rally_object(field, value)
      field_updates = {field => value}
      @rally_object.update(field_updates)
      @rally_object = @rally_object.read
    end

    private

    def define_rally_methods(methods)
      methods.each do | method |
        self.class.send :define_method, method do
          @rally_object.send(method.camelize)
        end

        self.class.send :define_method, method+'=' do | arg |
          update_rally_object(method.camelize, arg)
          self.send(method)
        end
      end
    end
  end
end
