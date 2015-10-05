require_relative 'base'
module Rally
  class Task < Base
    EDITABLE_TEXT_FIELDS.concat %w(estimate actuals to_do)
    EDITABLE_OBJECT_RELATIONS.concat %w(work_product)

    def self.find(filter, rally_cli, query = RallyAPI::RallyQuery.new)
      query = RallyAPI::RallyQuery.new
      query.type         = 'task'
      #query_conditions = ["State != Completed"]
      query.limit = 10
      query.page_size = 10
      super
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
