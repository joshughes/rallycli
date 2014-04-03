require 'spec_helper'

describe 'RallyCli' do

  let(:rally) {RallyCli.new}

  describe 'user login' do
    it 'should throw an error when authentication fails' do
      expect{RallyCli.new(username: 'foo', password: 'bar', project: 'tom')}.to raise_error(StandardError)
    end

    it 'should tell the user the current name and password' do
      expect(rally.user_name).to eq(ENV['RALLY_USERNAME'])
      expect(rally.password).to eq(ENV['RALLY_PASSWORD'])
    end

  end

  describe 'user tasks' do
    after(:all) do
      delete_all_test_tasks(rally)
    end

    it 'can create a new task' do
      expect { rally.create_task("My cool task","needs to do cool things!") }.to change{rally.tasks.count}.by(1)
    end 

    it 'retrives a list of user tasks' do
      rally.create_task("My cool task","needs to do cool things!")
      expect(rally.tasks.count).to be > 0
    end
  end


end