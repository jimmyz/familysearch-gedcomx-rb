require 'spec_helper'
require 'json'

describe FamilySearch::Gedcomx do
  it 'should have a version number' do
    FamilySearch::Gedcomx::VERSION.should_not be_nil
  end
  
  context "populating from hashes" do
    it 'should be able to parse a person file' do
      person_json = File.read 'spec/familysearch/gedcomx/fixtures/person.json'
      familysearch_hash = JSON.parse person_json
      fs_obj = FamilySearch::Gedcomx::FamilySearch.new familysearch_hash
      fs_obj.persons[0].class.should == FamilySearch::Gedcomx::Person
      fs_obj.persons[0].gender.class.should == FamilySearch::Gedcomx::Gender
      fs_obj.persons[0].gender.type.should == "http://gedcomx.org/Male"
    end
    
  end
end
