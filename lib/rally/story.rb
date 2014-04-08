require_relative 'base'
module Rally
  class Story < Base

    def self.create(story, user, rally_cli)
      rally_api = rally_cli.rally_api
      obj = {}
      obj["Name"]        = story[:name]
      obj["Description"] = story[:description]
      obj["Owner"]       = user.ObjectID
      self.new(rally_api.create("story", obj))
    end

    def self.stories_for_project(rally_cli)
      query = RallyAPI::RallyQuery.new
      query.type         = 'story'
      query.project      = {"_ref" => rally_cli.default_project_ref } 
      query.query_string = "((ScheduleState != Completed) AND (Owner.Name = #{rally_cli.config[:username]}))"
      rally_cli.rally_api.find(query)
    end


  end
end
