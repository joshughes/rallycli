require 'spec_helper'

describe 'RallyCli Base' do

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

  let(:base) {Rally::Base.new(rally_task)}

  before(:each) do
    Rally::Cli.stub(:rally_login).and_return(true)
  end

  describe 'build query' do
    it 'builds the query correctly for one query term' do
      query = ["ScheduleState != Completed"]
      expect(base.build_query(query)).to eq("(ScheduleState != Completed)")
    end

    it 'builds the query correctly for two query terms' do
      expected_query = "((ScheduleState != Completed) AND (Owner.Name = FooBar))"
      query = ["ScheduleState != Completed", "Owner.Name = FooBar"]
      expect(base.build_query(query)).to eq(expected_query)
    end
  end
end