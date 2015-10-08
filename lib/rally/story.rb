require_relative 'base'
module Rally
  class Story < Base

    EDITABLE_SELECT_FIELDS['expedite'] = ['Yes','No']

    def self.find(options, rally_cli, query_conditions = [])
      query_conditions << "ScheduleState != Completed"
      super(options, rally_cli, query_conditions)
    end

    def self.stories_for_project(rally_cli)
      stories = []
      query = RallyAPI::RallyQuery.new
      query.type         = 'story'
      query.project      = {"_ref" => rally_cli.default_project_ref }
      #AND (Owner.Name = #{rally_cli.config[:username]})
      query.query_string = "(ScheduleState != Completed)"
      query.limit = 10
      query.page_size = 10
      results = rally_cli.rally_api.find(query)
      results.each do |result|
        stories << Story.new(result.read)
      end
      stories
    end


  end
end
