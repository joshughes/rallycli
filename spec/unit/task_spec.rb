require 'spec_helper'

describe 'RallyCli Task' do

  let(:rally) {Rally::Cli.new}

  let(:rally_task) do 
    task = OpenStruct.new({
      Name:        'Test123', 
      Description: 'FooBar', 
      FormattedID: 'Heyoo',
      Actuals: 0})
    task.read= task
    task
  end

  let(:task) {Rally::Task.new(rally_task)}

  before(:each) do
    Rally::Cli.stub(:rally_login).and_return(true)
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
      Rally::Base.stub(:find_by_formattedID).and_return(rally_task)
      Rally::Task.save('current_task',task)
      loaded_task = Rally::Task.load('current_task', rally)
      expect(loaded_task.name).to         eq('Test123')
      expect(loaded_task.description).to  eq('FooBar')
      expect(loaded_task.formattedID).to  eq('Heyoo')
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
      rally_task.stub(:update).and_return(true)
      expected_time = ''
      Timecop.freeze(Time.current - 2.hours) do
        expected_time = Time.current
        task.start
      end

      Timecop.freeze(expected_time + 2.hours) do
        expect(task.progress).to eq(2)
        task.end
        expect(task.work_hours).to be_nil
        expect(task.start_time).to be_nil
      end
    end

    it 'to_yaml_properties' do
      expect(task.to_yaml_properties).not_to include(:@rally_task)
    end

    let(:methods) {%i(name ready description blocked blocked_reason estimate actuals to_do notes )}
    it 'has methods to update a task' do
      methods.each do | method |
        expect(Rally::Task.method_defined? method).to be_true
      end
    end

    it 'delegates to the rally api task correctly' do
      methods.each do | method |
        rally_task.send("#{method.to_s.camelize}=","delegated")
        expect(task.send(method)).to eq("delegated")
      end
    end

    it 'updates rally task when task is modified' do
      rally_task.stub(:update).and_return(true)
      methods.each do | method |
        task.send(method.to_s+"=",'FooBar')
        expect(rally_task).to have_received(:update).
          with({method.to_s.camelize => 'FooBar'})
      end
    end


  end


end