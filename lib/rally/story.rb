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
      stories = []
      query = RallyAPI::RallyQuery.new
      query.type         = 'story'
      query.project      = {"_ref" => rally_cli.default_project_ref }
      #AND (Owner.Name = #{rally_cli.config[:username]})
      query.query_string = "(ScheduleState != Completed)"
      results = rally_cli.rally_api.find(query)
      results.each do |result|
        stories << Story.new(result.read)
      end
      stories
    end


  end
end
