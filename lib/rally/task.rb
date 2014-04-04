module Rally
  class Task

    def self.create(task, story, user, rally_cli)
      rally_api = rally_cli.rally_api
      obj = {}
      obj["Name"]        = task[:name]
      obj["Description"] = task[:description]
      obj["WorkProduct"] = story.ObjectID
      obj["Owner"]       = user.ObjectID
      self.new(rally_api.create("task", obj))
    end

    def self.find_rally_task(formatted_id, rally_cli)
      query = RallyAPI::RallyQuery.new
      query.type         = 'task'
      query.query_string = "(FormattedID = #{formatted_id})"
      rally_cli.rally_api.find(query).first.read
    end

    def self.save(name,task)
      File.open(".rally_cli/#{name}.yaml", "w") do |file|
        file.puts YAML::dump(task)
      end
    end

    def self.load(name, rally_cli)
      file = File.open(".rally_cli/#{name}.yaml", "r")
      task = YAML.load(file)
      task.rally_task = Task.find_rally_task(task.formatted_id, rally_cli)
      task
    end

    attr_accessor :start_time, :rally_task, :name, :description, :formatted_id, 
                    :actual_hours

    def initialize(rally_task)
      @rally_task   = rally_task
      @name         = rally_task.Name
      @description  = rally_task.Description
      @formatted_id = rally_task.FormattedID
    end

    def start
      @start_time = Time.current
    end

    def end
      @actual_hours = ((Time.current - @start_time) / 1.hour).round
    end


    def to_yaml_properties
      variables = instance_variables
      variables.delete(:@rally_task)
      variables
    end

  end
end
