require 'active_support'
require 'active_support/core_ext'
require 'httpclient/webagent-cookie'
require 'rally_api'
require 'yaml'
require 'pry'
require_relative 'task'
require_relative 'story'

module Rally
  class Cli
    def initialize(options={})
      options.reverse_merge!({
        username:  ENV['RALLY_USERNAME'],
        password:  ENV['RALLY_PASSWORD'],
        base_url:  ENV['RALLY_BASE_URL'],
        project:   ENV['RALLY_PROJECT'],
        workspace: ENV['RALLY_WORKSPACE']
        })
      options.delete_if {|key, value| !value }

      @config = get_config_from_file || Hash.new
      @config.merge!(options)

      headers = RallyAPI::CustomHttpHeader.new()
      headers.name    = "rally_cli"
      headers.version = "0.1.0"

      @config[:headers] = headers
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
      Task.save("current_task",@task)
    end

    def current_story=(story)
      @story = story
      Story.save("current_story", @story)
    end

    def current_task
      @task ||= Task.load("current_task", self)
    end

    def current_story
      @story ||= Story.load("current_story", self)
    end

    def current_user
      query = RallyAPI::RallyQuery.new
      query.type         = 'user'
      query.fetch        = 'ObjectID'
      query.project      = {"_ref" => default_project_ref } if @config[:project]
      query.query_string = "(Name = #{@config[:username]})"
      @rally.find(query).first
    end

    def tasks(filter=[])
      Task.find(filter,self)
    end

    def create_task(task, story=current_story, user=current_user)
      Task.create(task, user, self, story)
    end

    def create_story(story, user=current_user, parent=nil)
      Story.create(story, user, self, parent)
    end

    def stories(options=[],story_filter=[])
      Story.find(options,self,story_filter)
    end

    alias_method :work_products, :stories

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
