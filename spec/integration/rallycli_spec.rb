require 'spec_helper'

describe 'RallyCli' do

  let(:rally) {Rally::Cli.new}

  describe 'user login' do
    it 'should throw an error when authentication fails' do
      expect{RallyCli.new(username: 'foo', password: 'bar', project: 'FooBar')}.to raise_error(StandardError)
    end

    it 'should tell the user the current name and password' do
      expect(rally.user_name).to eq(ENV['RALLY_USERNAME'])
      expect(rally.password).to eq(ENV['RALLY_PASSWORD'])
    end

  end

  
  let(:test_story) { {name: "My cool story", description: "needs to do cool things!" } }
  describe 'user tasks' do
    

    let(:test_task) { {name: "My cool task", description: "needs to do cool things!"} }
    let(:test_story_object) {rally.create_story(test_story)}

    after(:all) do
      delete_all_test_tasks(rally)
    end

    it 'can create a new task' do
      expect { rally.create_task(test_task, test_story_object) }.to change{rally.tasks.count}.by(1)
    end 

    it 'retrives a list of tasks assigned to the user' do
      rally.create_task(test_task, test_story_object)
      expect(rally.tasks.count).to be > 0
    end
  end

  describe 'user stories' do
    
    after(:all) do
      delete_all_test_stories(rally)
    end

    it 'can create a new user story' do
      expect { rally.create_story(test_story) }.to change{rally.project_stories.count}.by(1)
    end
    it 'can give the user open stories from the current iteration' do
    end
    it 'can give the user open stories for the current project' do
      expect(rally.project_stories.count).to be > 0
    end

  end

end