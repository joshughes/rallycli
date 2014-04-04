module Rally
  class Story

    def self.create(story, user, rally_cli)
      rally_api = rally_cli.rally_api
      obj = {}
      obj["Name"]        = story[:name]
      obj["Description"] = story[:description]
      obj["Owner"]       = user.ObjectID
      self.new(rally_api.create("story", obj))
    end

    def self.find_rally_story(formatted_id, rally_cli)
      query = RallyAPI::RallyQuery.new
      query.type         = 'stroy'
      query.query_string = "(FormattedID = #{formatted_id})"
      rally_cli.rally_api.find(query).first.read
    end

    def self.stories_for_project(rally_cli)
      query = RallyAPI::RallyQuery.new
      query.type         = 'story'
      query.project      = {"_ref" => rally_cli.default_project_ref } 
      query.query_string = "((ScheduleState != Completed) AND (Owner.Name = #{rally_cli.config[:username]}))"
      rally_cli.rally_api.find(query)
    end

    def self.save(name,task)
      File.open(".rally_cli/#{name}.yaml", "w") do |file|
        file.puts YAML::dump(task)
      end
    end

    def self.load(name, rally_cli)
      file = File.open(".rally_cli/#{name}.yaml", "r")
      task = YAML.load(file)
      task.rally_story = Story.find_rally_story(task.formatted_id, rally_cli)
      task
    end

    attr_accessor :start_time, :rally_story, :name, :description, :formatted_id

    def initialize(rally_story)
      @rally_story  = rally_story
      @name         = rally_story.Name
      @description  = rally_story.Description
      @formatted_id = rally_story.FormattedID
    end

    def object_id
      @rally_story.ObjectID
    end

    def to_yaml_properties
      variables = instance_variables
      variables.delete(:@rally_story)
      variables
    end

  end
end
