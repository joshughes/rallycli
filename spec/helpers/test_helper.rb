module TestHelper
  def delete_all_test_tasks(rally)
    rally.tasks.each do |task|
      task.delete
    end
  end

  def delete_all_test_stories(rally)
    rally.project_stories.each do |story|
      story.delete
    end
  end

end