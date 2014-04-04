require 'active_support'
require 'active_support/core_ext'
require 'rally_api'
require 'yaml'
require 'pry'
require_relative 'task'
require_relative 'story'

module Rally
  class Cli
    def initialize(options={})
      options.reverse_merge!({
        username: ENV['RALLY_USERNAME'],
        password: ENV['RALLY_PASSWORD'],
        base_url: ENV['RALLY_BASE_URL']
        })

      @config = get_config_from_file[:rally_options] || Hash.new
      @config.merge!(options)

      headers = RallyAPI::CustomHttpHeader.new()
      headers.name    = "rally_cli"
      headers.version = "0.1.0"

      @config[:headers]    = headers

      rally_login
    end

    def user_name
      @config[:username]
    end

    def password
      @config[:password]
    end

    def project
      @config[:project]
    end

    def workspace
      @config[:workspace]
    end

    def current_task=(task)
      @task = task
      Task.save("curren_task",@task)
    end

    def current_task
      @task ||= Task.load("current_task")
    end

    def current_story
      @story ||= Task.load("current_story")
    end

    def current_user
      query = RallyAPI::RallyQuery.new
      query.type         = 'user'
      query.fetch        = 'ObjectID'
      query.project      = {"_ref" => default_project_ref } if @config[:project]
      query.query_string = "(Name = #{@config[:username]})"
      @rally.find(query).first
    end

    def tasks
      query = RallyAPI::RallyQuery.new
      query.type         = 'task'
      query.fetch        = 'FormattedID'
      query.project      = {"_ref" => @rally.rally_default_project.ref } if @config[:project]
      query.query_string = "((Owner.Name = #{@config[:username]}) AND (State != Completed))"
      @rally.find(query)
    end

    def create_task(task, story=current_story)
      Task.create(task, story, current_user, self)
    end

    def create_story(story)
      Story.create(story,current_user,self)
    end

    def project_stories
      Story.stories_for_project(self)
    end

    def default_project_ref
      @rally.rally_default_project.ref
    end

    def rally_api
      @rally
    end

    def config
      @config
    end


    private

    def rally_login
      @rally ||= RallyAPI::RallyRestJson.new(@config)
    end

    def get_config_from_file
      config_file = ENV['RALLY_CLI_CONFIG'] || '.rally_cli.yml'
      if File.exist?(config_file)
        YAML.load_file(config_file).deep_symbolize_keys!
      else
        Hash.new
      end
    end

  end
end
