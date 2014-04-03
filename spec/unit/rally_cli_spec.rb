require 'spec_helper'

describe 'RallyCli' do

  let(:rally) {RallyCli.new}

  before(:each) do
    allow_any_instance_of(RallyCli).to receive(:rally_login).and_return(true)
  end

  describe 'reads properties from the current directory' do

    it 'should read configuration from the workspace' do
      ENV['RALLY_CLI_CONFIG'] = 'spec/support/test_config.yml'
      expect(rally.project).to eq('FooBarProject')
      expect(rally.workspace).to eq('YOLO')
    end

  end

  describe 'task management' do
    it 'allows a user to start work on a task' do
      expected_time = ''
      Timecop.freeze(Time.current - 2.hours) do
        expected_time = Time.current
        rally.current_task.start
      end
      expect(rally.current_task.start_time).to eq(expected_time)
    end

    it 'allows a user to update a task estimate' do
      rally.current_task.estimate = 8
      expect(rally.current_task.estimate).to eq(8)
    end

    it 'allows a user to get details on the current task' do
      pending("something else getting finished")
    end

    it 'allows a user to update a tasks progress' do
      pending("something else getting finished")
    end
  end

  describe 'story management' do
    it 'allows a user to start work on a story' do
      pending("something else getting finished")
    end

    it 'allows a user to update a story estimate' do
      pending("something else getting finished")
    end

    it 'allows a user to get details on the current story' do
      pending("something else getting finished")
    end

    it 'allows a user to update a storys progress' do
      pending("something else getting finished")
    end
  end




end
