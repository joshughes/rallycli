require 'spec_helper'

describe 'RallyCli' do

  let(:rally) {Rally::Cli.new}

  let(:iteration) do
    rally_api = rally.rally_api
    obj = {}
    obj["Name"]        = "TestIteration"
    obj["StartDate"]   = Time.current
    obj["EndDate"]     = Time.current + 2.days
    obj["State"]       = "Planning"
    rally_api.create("iteration", obj)
  end

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

    describe 'retrives a list of tasks' do

      it 'for the current story',test_construct: true do
        rally.current_story = test_story_object
        story2 = rally.create_story(test_story)

        rally.create_task(test_task, test_story_object)
        rally.create_task(test_task, story2)

        expect(rally.tasks([:current_story]).count).to eq 1
        expect(rally.tasks.count).to be > 1
      end

      it 'outside the current user' do
        task = rally.create_task(test_task, test_story_object)
        expect { task.owner = nil }.to change{rally.tasks([:all_users]).count - rally.tasks.count}.by(1)
        task.rally_object.delete
      end

      describe 'for the current iteration' do
        it 'when tasks exist outside the iteration' do
          test_story_object.update_rally_object("Iteration.ObjectID", iteration.ObjectID)
          story2 = rally.create_story(test_story)

          rally.create_task(test_task, test_story_object)
          rally.create_task(test_task, story2)

          expect(rally.tasks.count).to be > 1
          expect(rally.tasks([:current_iteration]).count).to eq 1
        end

        after(:each) do
          iteration.delete
        end
      end
    end
  end

  describe 'user stories' do

    after(:all) do
      delete_all_test_stories(rally)
    end

    it 'can create a new user story' do
      expect { rally.create_story(test_story) }.to change{rally.stories.count}.by(1)
    end
    it 'retrieves only stories in the current iteration' do

    end
    it 'retrives stories from the current project'

  end

end
