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
    menu = {
      options:       @rally_cli.tasks(options),
      prompt:        "Please choose the task you wish to work on.",
      option_text:   proc { |option| "#{option.formattedID}: #{option.description}"},
      option_action: proc { |option| @rally_cli.current_task = option; exit }
    }  
    menu_select(menu)
  end
end

command :set_story do |c|
  c.syntax = 'rally_cli set_story [options]'
  c.description = 'Display stories for the user to select a story to work on'
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    menu = {
      options:       @rally_cli.stories(options),
      prompt:        "Please choose the story you wish to work on.",
      option_text:   proc { |option| "#{option.formattedID}: #{option.description}"},
      option_action: proc { |option| @rally_cli.current_story = option; exit}
    }
    menu_select(menu)
  end
end

command :edit_task do |c|
  c.syntax = 'rally_cli edit_task [options]'
  c.description = 'Edit a feild of the current task'
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    edit_object(@task, args[0])
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


private 


def edit_object(object, edit_field, options=nil)
  if(object.class::EDITABLE_TEXT_FIELDS.include?(edit_field))
    current_value = object.send(edit_field)
    object.send(edit_field+"=", ask_editor(current_value))
  elsif(object.class::EDITABLE_BOOLEAN_FIELDS.include?(edit_field))
    object.send(edit_field+"=",@high_line.agree("Is #{object.formattedID} #{edit_field}?"))
  elsif(object.class::EDITABLE_OBJECT_RELATIONS.include?(edit_field))
    menu ={
      options:       @rally_cli.send("#{edit_field.pluralize}",options),
      prompt:        "Please choose the new #{edit_field} for #{object.class} #{object.formattedID}",
      option_text:   proc { |option| "#{option.formattedID}: #{option.name}"},
      option_action: proc { |option| object.send("#{edit_field}=",option.objectID); exit}
    }
    menu_select(menu)
  else
    say("#{edit_field.capitalize} is not editable for #{object.class} #{object.formattedID}")
  end
end

def menu_select(menu_hash)
  groups = menu_hash[:options].each_slice(10).to_a
  groups.cycle do |options|
    system("clear")
    @high_line.choose do | menu |
      menu.prompt = menu_hash[:prompt] 
      menu.prompt += "\n next: for next 10 results" if groups.length > 1
      menu.prompt += "\n quit: to exit"
      menu.shell  = false

      options.each do |option|
        menu.choice(menu_hash[:option_text].call(option)) { menu_hash[:option_action].call(option) }
      end
      menu.hidden(:next, "Next page") { next }
      menu.hidden(:quit, "Exit program.") { exit }
    end
  end
end


