require 'spec_helper'

describe 'Cli Story' do

  let(:rally) {Rally::Cli.new}

  let(:rally_story) do 
    OpenStruct.new({
      Name:        'Test123', 
      Description: 'FooBar', 
      FormattedID: 'Heyoo'})
  end

  let(:story) {Rally::Story.new(rally_story)}

  before(:each) do
    Rally::Cli.stub(:rally_login).and_return(true)
  end

  describe 'class methods', test_construct: true do
    before(:each) do
      example.metadata[:construct].directory('.rally_cli')
    end

    it 'save' do
      Rally::Story.save('current_story',story)
      expect(File.exists?(".rally_cli/current_story.yaml")).to be_true
    end

    it 'load', test_construct: true do
      Rally::Story.stub(:find_by_formattedID).and_return(rally_story)
      Rally::Story.save('current_story',story)
      loaded_story = Rally::Story.load('current_story', rally)
      expect(loaded_story.name).to         eq('Test123')
      expect(loaded_story.description).to  eq('FooBar')
      expect(loaded_story.formattedID).to eq('Heyoo')
    end
  end

  describe 'Story methods' do

    it 'to_yaml_properties' do
      expect(story.to_yaml_properties).not_to include(:@rally_object)
    end

  end


end