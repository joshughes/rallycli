require_relative 'base'
module Rally
  class Task < Base
    EDITABLE_TEXT_FIELDS.concat %w(estimate actuals to_do)
    EDITABLE_OBJECT_RELATIONS.concat %w(work_product)

    def self.find(options, rally_cli, query_conditions = [])
      if !options.include?(:all_stories) && rally_cli.current_story
        query_conditions << "WorkProduct.ObjectID = #{rally_cli.current_story.objectID}"
      end
      super(options, rally_cli, query_conditions)
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
      if actuals
        self.actuals = actuals + @work_hours
      else
        self.actuals = @work_hours
      end
      @start_time = nil
      @work_hours = nil
    end
  end
end
