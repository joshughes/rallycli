require 'active_support'
require 'active_support/core_ext'
require 'rally_api'
require 'yaml'
require 'pry'
require_relative 'rally/task'

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
    headers.version = "0.2.0"

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

  def current_task
    @task ||= Rally::Task.new
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
    query.fetch        = 'FormattedID,Project'
    query.project      = {"_ref" => @rally.rally_default_project.ref } if @rally_config[:project]
    query.query_string = "(Owner.Name = #{@rally_config[:username]})"
    @rally.find(query)
  end

  def create_task(name, description, story = self.current_story)
    obj = {}
    obj["Name"]        = name
    obj["Description"] = description
    obj["WorkProduct"] = story.ObjectID
    obj["Owner"]       = current_user.ObjectID
    @rally.create("task", obj)
  end




  private

  def rally_login
    RallyAPI::RallyRestJson.const_set("DEFAULT_WSAPI_VERSION", "v2.0")
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
