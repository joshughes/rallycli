require 'spec_helper'

describe 'RallyCli Base' do
  let(:query) { ["ScheduleState != Completed"] }
  describe 'build query' do
    it 'builds the query correctly for one query term' do
      expect(Rally::Base.build_query(query)).to eq("(ScheduleState != Completed)")
    end

    it 'builds the query correctly for two query terms' do
      expected_query = "((ScheduleState != Completed) AND (Owner.Name = FooBar))"
      query << "Owner.Name = FooBar"
      expect(Rally::Base.build_query(query)).to eq(expected_query)
    end

    it 'builds queries over two conditions correctly' do
      expected_query = "(((ScheduleState != Completed) AND (Owner.Name = FooBar)) AND (This.is = Dog))"
      query << "Owner.Name = FooBar"
      query << "This.is = Dog"
      expect(Rally::Base.build_query(query)).to eq(expected_query)
    end
  end
end