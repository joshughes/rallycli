module TaskHelper
  def delete_all_test_tasks(rally)
    rally.tasks.each do |task|
      task.delete
    end
  end
end