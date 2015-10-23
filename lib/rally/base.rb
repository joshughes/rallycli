require 'fileutils'
require 'ostruct'
require 'parallel'
module Rally
  class Base
    EDITABLE_TEXT_FIELDS = %w(name description blocked_reason notes)
    MARKDOWN_TEXT_FIELDS = %w(description notes)
    EDITABLE_BOOLEAN_FIELDS = %w(ready blocked)
    EDITABLE_OBJECT_RELATIONS = %w(owner)
    EDITABLE_SELECT_FIELDS = {}
    RULES = {}

    def self.save(name, task)
      FileUtils.mkdir_p('.rally_cli') unless File.directory?('.rally_cli')
      File.open(".rally_cli/#{name}.yaml", 'w') do |file|
        file.puts YAML.dump(task)
      end
    end

    def self.create(object, user, rally_cli, parent = nil)
      rally_api = rally_cli.rally_api
      if object.instance_of? OpenStruct
        hash = object.marshal_dump
      else
        hash = object
      end
      new_object = rally_hash(hash)
      new_object['Owner']       = user.ObjectID
      new_object['WorkProduct'] = parent.objectID if parent
      new(rally_api.create(rally_type.to_s, new_object), rally_cli.config)
    end

    def self.rally_hash(hash)
      rally_hash = {}
      hash.each do |key, value|
        rally_hash[key.to_s.camelize] = value
      end
      rally_hash
    end

    def self.rally_type
      name.downcase.demodulize.to_sym
    end

    def self.rally_methods(config = nil)
      if config
        if config.include?(:custom_fields) && config[:custom_fields].include?(rally_type)
          config[:custom_fields][rally_type].each do |field_type, fields|
            next unless 'EDITABLE_SELECT_FIELDS' == "EDITABLE_#{field_type.upcase}"
            fields.each do |field_name, field_value|
              EDITABLE_SELECT_FIELDS[field_name.to_s] = field_value
            end
          end
        end
      end
      EDITABLE_TEXT_FIELDS + EDITABLE_BOOLEAN_FIELDS + EDITABLE_OBJECT_RELATIONS + EDITABLE_SELECT_FIELDS.keys
    end

    def self.define_rules(config = nil)
      if config
        if config.include?(:rules) && config[:rules].include?(rally_type)
          config[:rules][rally_type].each do |rule, actions|
            RULES[rule] = actions
          end
        end
      end
    end

    def self.load(file_name, rally_cli)
      file_path = ".rally_cli/#{file_name}.yaml"
      if File.exist?(file_path)
        file = File.open(file_path, 'r')
        object = YAML.load(file)
        rally_object = find_by_formattedID(object.formattedID, rally_cli)
        return object.class.new rally_object, rally_cli.config, object
      else
        return nil
      end
    end

    def self.find_by_formattedID(formattedID, rally_cli)
      rally_object_name = name.split('::').last.downcase
      query = RallyAPI::RallyQuery.new
      query.type         = rally_object_name
      query.query_string = "(FormattedID = #{formattedID})"
      rally_cli.rally_api.find(query).first.read
    end

    def self.find(options, rally_cli, query_conditions = [])
      query = RallyAPI::RallyQuery.new
      options ||= []
      rally_api = rally_cli.rally_api
      objects = []

      query.type = rally_type.to_s
      query.limit = 10

      query.project = { '_ref' => rally_api.rally_default_project.ref } if rally_cli.config[:project]

      unless options.include?(:all_iterations)
        query_conditions << 'Iteration.StartDate <= today'
        query_conditions << 'Iteration.EndDate >= today'
      end
      unless options.include?(:all_users)
        query_conditions << "Owner.Name = #{rally_cli.config[:username]}"
      end
      query.query_string = build_query(query_conditions)
      results = rally_api.find(query)
      Parallel.each(results, in_threads: 4) do |result|
        objects << new(result.read)
      end
      objects
    end

    def self.build_query(query_objects)
      query_string = "(#{query_objects[0]})"
      if query_objects.length >= 2
        query_string += " AND (#{query_objects[1]})"
        query_string.prepend '('
        query_string += ')'
        if query_objects.length > 2
          return '(' + query_string + ' AND ' + build_query(query_objects[2..(query_objects.length-1)]) + ')'
        else
          return query_string
        end
      else
        return '(' + query_objects.first + ')'
      end
    end

    attr_accessor :rally_object
    attr_reader :formattedID, :objectID

    def initialize(rally_object, config = nil, object = nil)
      @rally_object   = rally_object
      @formattedID    = rally_object.FormattedID
      @objectID       = rally_object.ObjectID
      define_rally_methods self.class.rally_methods(config)
      self.class.define_rules(config)
      load(object) if object
    end

    def update(update_hash)
      update_hash = self.class.rally_hash(execute_rules(update_hash))
      @rally_object.update(update_hash)
    end

    def to_yaml_properties
      variables = instance_variables
      variables.delete(:@rally_object)
      variables
    end

    def load(object)
      return unless object
      @formattedID = object.formattedID
      @objectID    = object.objectID
    end

    def execute_rules(fields)
      rules_output = {}
      fields.each do |field, value|
        next unless RULES.include?(field.underscore.to_sym)
        RULES[field.underscore.to_sym].each do |rule|
          next unless value == rule[:is]
          rules_output[rule[:then][:field].to_s.camelize] = rule[:then][:value]
        end
      end
      rules_output.merge(fields)
    end

    private

    def define_rally_methods(methods)
      methods.each do |method|
        self.class.send :define_method, method do
          @rally_object.send(method.camelize)
        end

        self.class.send :define_method, method + '=' do |arg|
          fields = {}
          fields[method.camelize] = arg
          update(fields)
          send(method)
        end
      end
    end
  end
end
