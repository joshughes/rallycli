require 'fileutils'
module Rally
  class Base
      RALLY_METHODS = %w(name description ready actual blocked work_product blocked_reason to_do notes)
      def self.save(name,task)
        unless File.directory?('.rally_cli')
          FileUtils.mkdir_p('.rally_cli')
        end
        File.open(".rally_cli/#{name}.yaml", "w") do |file|
          file.puts YAML::dump(task)
        end
      end

      def self.load(file_name, rally_cli)
        file = File.open(".rally_cli/#{file_name}.yaml", "r")
        object = YAML.load(file)
        rally_object =  self.find_by_formattedID(object.formattedID, rally_cli)
        object.class.new rally_object, object
      end

      def self.find_by_formattedID(formattedID, rally_cli)
        rally_object_name = self.name.split('::').last.downcase
        query = RallyAPI::RallyQuery.new
        query.type         = rally_object_name
        query.query_string = "(FormattedID = #{formattedID})"
        rally_cli.rally_api.find(query).first.read
      end

      attr_accessor :rally_object
      attr_reader   :formattedID, :objectID

      def initialize(rally_object, object=nil)
        @rally_object   = rally_object
        @formattedID    = rally_object.FormattedID
        @objectID       = rally_object.ObjectID
        define_rally_methods self.class::RALLY_METHODS
        load(object)
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

      private 

      def define_rally_methods(methods)
        methods.each do | method |
          self.class.send :define_method, method do 
            @rally_object.send(method.camelize)
          end

          self.class.send :define_method, method+'=' do | arg |
            field_updates = {method.camelize => arg}
            @rally_object.update(field_updates)
            @rally_object = @rally_object.read
            self.send(method)
          end
        end
      end

  end
end