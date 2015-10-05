module TestHelper
  def delete_all_test_tasks(rally)
    rally.tasks([:all_iterations]).each do |task|
      task.rally_object.delete
    end
  end

  def delete_all_test_stories(rally)
    rally.stories([:all_iterations]).each do |story|
      story.rally_object.delete
    end
  end

end
