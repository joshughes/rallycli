require_relative 'base'
module Rally
  class Task < Base
    RALLY_METHODS.concat %w(estimate actuals)

    def self.create(task, story, user, rally_cli)
      rally_api = rally_cli.rally_api
      obj = {}
      obj["Name"]        = task[:name]
      obj["Description"] = task[:description]
      obj["WorkProduct"] = story.objectID
      obj["Owner"]       = user.ObjectID
      self.new(rally_api.create("task", obj))
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
      if(object)
        @start_time   = object.start_time
        @work_hours   = object.work_hours
      end
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
