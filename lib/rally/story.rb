require_relative 'base'
module Rally
  class Story < Base
    EDITABLE_OBJECT_RELATIONS.concat %w(parent)

    def self.find(options, rally_cli, query_conditions = [])
      query_conditions << 'ScheduleState != Completed'
      super(options, rally_cli, query_conditions)
    end
  end
end
