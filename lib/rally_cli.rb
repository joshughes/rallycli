#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require_relative 'rally/cli'

program :version, '0.0.1'
program :description, 'Command line interface for Rally'

@rally_cli = Rally::Cli.new
@task = @rally_cli.current_task
@high_line = HighLine.new
 
command :current_task do |c|
  c.syntax = 'rally_cli current_task [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    say("#{@task.formattedID}: #{@task.name} - #{@task.description}")
  end
end

command :start_work do |c|
  c.syntax = 'rally_cli start_work [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    @task.start
    say("Work started on #{@task.formattedID}")
  end
end

command :end_work do |c|
  c.syntax = 'rally_cli end_work [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    @task.end
    say("Work ended with #{@task.work_hours} hours logged this session and a total of #{@task.actuals} hours logged for task #{@task.formattedID}")
  end
end

command :work_progress do |c|
  c.syntax = 'rally_cli work_progress [options]'
  c.description = 'Display the hours spent on the current_task'
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    say("You have spent #{@task.progress} hours working on task #{@task.formattedID}")
  end
end

command :set_task do |c|
  c.syntax = 'rally_cli set_task [options]'
  c.description = 'Display tasks for the user to select a task to work on'
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    task_groups = @rally_cli.tasks(options).each_slice(10).to_a
    task_groups.cycle do |tasks|
      system("clear")
      @high_line.choose do | menu |
        menu.prompt = "Please choose the task you wish to work on."
        menu.shell  = false

        tasks.each do |task|
          menu.choice("#{task.formattedID}: #{task.description}") { @rally_cli.current_task = task; exit }
        end
        menu.hidden(:next, "Next page of tasks") { next }
        menu.hidden(:quit, "Exit program.") { exit }
      end
    end
  end
end

command :set_story do |c|
  c.syntax = 'rally_cli set_story [options]'
  c.description = 'Display stories for the user to select a story to work on'
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    story_groups = @rally_cli.stories(options).each_slice(10).to_a
    story_groups.cycle do |stories|
      @high_line.choose do | menu |
        menu.prompt = "Please choose the story you wish to work on."
        menu.shell  = false

        stories.each do |story|
          menu.choice("#{story.formattedID}: #{stroy.description}") { @rally_cli.current_story = story; exit }
        end
        menu.hidden(:next, "Next page of stories") { next }
        menu.hidden(:quit, "Exit program.") { exit }
      end
    end
  end
end

command :edit_task do |c|
  c.syntax = 'rally_cli edit_task [options]'
  c.description = 'Edit a feild of the current task'
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    @task.description = ask_editor(@task.description)
  end
end

command :edit_story do |c|
  c.syntax = 'rally_cli edit_story [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    # Do something or c.when_called Rally_cli::Commands::Edit_story
  end
end

