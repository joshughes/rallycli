require 'thor'
require "highline/import"
require_relative 'rally/cli'

class RallyCli < Thor
  def initialize(*args)
    super(*args)
    @rally_cli = Rally::Cli.new
    @high_line = HighLine.new
    @task = @rally_cli.current_task
  end

  desc "current_task", "returns current task if set"
  def current_task
    say("#{@task.formattedID}: #{@task.name} - #{@task.description}")
  end

  desc "start_work", "starts work on the current task"
  def start_work
    @task.start
    say("Work started on #{@task.formattedID}")
  end

  desc "end_work", "ends work on the current task and updates actual hours on rally"
  def end_work
    @task.end
    say("Work ended with #{@task.work_hours} hours logged this session and a total of #{@task.actuals} hours logged for task #{@task.formattedID}")
  end

  desc "work_progress", "gets the number of hours logged for current_task"
  def work_progress
    say("You have spent #{@task.progress} hours working on task #{@task.formattedID}")
  end

  desc "set_current_task", "choose the task to start work on"
  option :all_users, type: :boolean, aliases: :au, desc: 'ignore user file fetching tasks'
  option :interation, type: :boolean, aliases: :i, desc: 'scope task search to current_iteration instead of current_story'
  option :project, type: :boolean, aliases: :p, desc: 'scope task search to the project level instead of only the current_story'
  def set_current_task
    loop do
      task_groups = @rally_cli.tasks(options).each_slice(10).to_a
      task_groups.cycle do |tasks|
        @high_line.choose do | menu |
          menu.prompt = "Please choose the task you wish to work on."
          menu.shell  = false

          tasks.each do |task|
            menu.choice("#{task.formattedID}: #{task.description}") { @rally_cli.current_task = task }
          end
          menu.hidden(:next, "Next page of tasks") { next }
          menu.hidden(:quit, "Exit program.") { exit }
        end
      end
    end
  end

  desc "set_current_story", "choose the story to work on"
  option :all_users, type: :boolean, aliases: :au, desc: 'ignore user file fetching stories'
  option :project, type: :boolean, aliases: :p, desc: 'scope story search to the project level instead of only the current_iteration'
  def set_current_story
    loop do
      story_groups = @rally_cli.stories(options).each_slice(10).to_a
      story_groups.cycle do |stories|
        @high_line.choose do | menu |
          menu.prompt = "Please choose the story you wish to work on."
          menu.shell  = false

          stories.each do |story|
            menu.choice("#{story.formattedID}: #{stroy.description}") { @rally_cli.current_story = story }
          end
          menu.hidden(:next, "Next page of stories") { next }
          menu.hidden(:quit, "Exit program.") { exit }
        end
      end
    end
  end


end



RallyCli.start(ARGV)