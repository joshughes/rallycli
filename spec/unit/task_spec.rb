require 'spec_helper'

describe 'RallyCli Task' do

  let(:rally) {Rally::RallyCli.new}

  let(:rally_task) do 
    OpenStruct.new({
      Name:        'Test123', 
      Description: 'FooBar', 
      FormattedID: 'Heyoo'})
  end

  let(:task) {Rally::Task.new(rally_task)}

  before(:each) do
    Rally::RallyCli.stub(:rally_login).and_return(true)
  end

  describe 'class methods', test_construct: true do
    before(:each) do
      example.metadata[:construct].directory('.rally_cli')
    end

    it 'save' do
      Rally::Task.save('current_task',task)
      expect(File.exists?(".rally_cli/current_task.yaml")).to be_true
    end

    it 'load', test_construct: true do
      Rally::Task.stub(:find_rally_task).and_return(rally_task)
      Rally::Task.save('current_task',task)
      loaded_task = Rally::Task.load('current_task', rally)
      expect(loaded_task.name).to         eq('Test123')
      expect(loaded_task.description).to  eq('FooBar')
      expect(loaded_task.formatted_id).to eq('Heyoo')
    end
  end

  describe 'task methods' do

    it 'start' do
      expected_time = ''
      Timecop.freeze(Time.current - 2.hours) do
        expected_time = Time.current
        task.start
      end
      expect(task.start_time).to eq(expected_time)
    end

    it 'end' do
      expected_time = ''
      Timecop.freeze(Time.current - 2.hours) do
        expected_time = Time.current
        task.start
      end

      Timecop.freeze(expected_time + 2.hours) do
        task.end
        expect(task.actual_hours).to eq(2)
      end
    end

  end


end