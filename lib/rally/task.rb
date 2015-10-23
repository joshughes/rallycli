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
  end
end
