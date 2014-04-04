require 'active_support'
require 'active_support/core_ext'
require 'rally_api'
require 'yaml'
require 'pry'
require_relative 'rally/task'
module Rally
  class RallyCli
    def initialize(options={})
      options.reverse_merge!({
        username: ENV['RALLY_USERNAME'],
        password: ENV['RALLY_PASSWORD'],
        base_url: ENV['RALLY_BASE_URL']
        })

      @rally_config = get_config_from_file[:rally_options] || Hash.new
      @rally_config.merge!(options)

      headers = RallyAPI::CustomHttpHeader.new()
      headers.name    = "rally_cli"
      headers.version = "0.1.0"

      @rally_config[:headers]    = headers

      rally_login
    end

    def user_name
      @rally_config[:username]
    end

    def password
      @rally_config[:password]
    end

    def project
      @rally_config[:project]
    end

    def workspace
      @rally_config[:workspace]
    end

    def current_task=(task)
      @task = task
      Task.save("curren_task",@task)
    end

    def current_task
      @task ||= Task.load("current_task")
    end

    def current_story
      query = RallyAPI::RallyQuery.new
      query.type         = 'story'
      query.fetch        = 'ObjectID'
      query.project      = {"_ref" => @rally.rally_default_project.ref } if @rally_config[:project]
      query.query_string = "(FormattedID = US2167)"
      @rally.find(query).first
    end

    def current_user
      query = RallyAPI::RallyQuery.new
      query.type         = 'user'
      query.fetch        = 'ObjectID'
      query.project      = {"_ref" => @rally.rally_default_project.ref } if @rally_config[:project]
      query.query_string = "(Name = #{@rally_config[:username]})"
      @rally.find(query).first
    end

    def tasks
      query = RallyAPI::RallyQuery.new
      query.type         = 'task'
      query.fetch        = 'FormattedID'
      query.project      = {"_ref" => @rally.rally_default_project.ref } if @rally_config[:project]
      query.query_string = "(Owner.Name = #{@rally_config[:username]})"
      @rally.find(query)
    end

    def create_task(task, story = current_story)
      Task.create(task, current_story, current_user, self)
    end

    def rally_api
      @rally
    end


    private

    def rally_login
      @rally ||= RallyAPI::RallyRestJson.new(@rally_config)
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
