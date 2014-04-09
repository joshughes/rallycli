module TestHelper
  def delete_all_test_tasks(rally)
    rally.tasks.each do |task|
      task.rally_object.delete
    end
  end

  def delete_all_test_stories(rally)
    rally.project_stories.each do |story|
      story.rally_object.delete
    end
  end

end