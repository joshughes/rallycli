require_relative 'base'
module Rally
  class Task < Base
    EDITABLE_TEXT_FIELDS.concat %w(estimate actuals to_do)
    EDITABLE_OBJECT_RELATIONS.concat %w(work_product)

    def self.create(task, story, user, rally_cli)
      rally_api = rally_cli.rally_api
      obj = {}
      obj["Name"]        = task[:name]
      obj["Description"] = task[:description]
      obj["WorkProduct"] = story.objectID
      obj["Owner"]       = user.ObjectID
      self.new(rally_api.create("task", obj))
    end

    def self.find(filter, rally_cli)
      rally_api = rally_cli.rally_api
      tasks = []
      query_conditions = ["State != Completed"]
      query = RallyAPI::RallyQuery.new
      query.type         = 'task'
      query.project      = {"_ref" => rally_api.rally_default_project.ref } if rally_cli.config[:project]
      if(filter.include?(:current_story))
        query_conditions << "WorkProduct.ObjectID = #{rally_cli.current_story.objectID}"
      elsif(filter.include?(:current_iteration))
        query_conditions << "Iteration.StartDate <= today"
        query_conditions << "Iteration.EndDate >= today"
      end
      unless(filter.include?(:all_users))
        query_conditions << "Owner.Name = #{rally_cli.config[:username]}"
      end
      query.query_string = Task.build_query(query_conditions)
      results = rally_api.find(query)
      results.each do |result|
        tasks << Task.new(result.read)
      end
      tasks
    end

    attr_accessor :start_time, :work_hours

    def start
      @start_time = Time.current
      self.class.save('current_task', self)
    end

    def end
      @work_hours = progress
      self.class.save('current_task', self)
      update_actuals
    end

    def progress
      ((Time.current - @start_time) / 1.hour).round
    end

    def load(object)
      super
      @start_time   = object.start_time
      @work_hours   = object.work_hours
    end

    private

    def update_actuals
      if self.actuals
        self.actuals = self.actuals + @work_hours
      else
        self.actuals = @work_hours
      end
      @start_time = nil
      @work_hours = nil
    end

  end
end
