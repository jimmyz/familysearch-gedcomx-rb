require 'spec_helper'
require 'json'

describe FamilySearch::Gedcomx::AtomFeed do
  it 'should have a version number' do
    FamilySearch::Gedcomx::VERSION.should_not be_nil
  end
  
  context "populating from hashes" do
    it 'should be able to parse a person file' do
      person_json = File.read 'spec/familysearch/gedcomx/fixtures/search.json'
      search_hash = JSON.parse person_json
      atom = FamilySearch::Gedcomx::AtomFeed.new search_hash
      atom.links['next'].href.should == 'https://familysearch.org/platform/tree/search?context=AQATNTkyODE4NTI0Mzc0ODEyODY4MwAAAAlSRSUSAFHXqwA%3D&start=15'
      atom.results.should == 4200
      atom.entries[0].should be_instance_of FamilySearch::Gedcomx::AtomEntry
      atom.entries[0].content.should be_instance_of FamilySearch::Gedcomx::AtomContent
      atom.entries[0].content.gedcomx.persons[0].should be_instance_of FamilySearch::Gedcomx::Person
      atom.entries[0].content.gedcomx.persons[0].full_name.should == 'John Smith'
      atom.entries[0].confidence.should == 5
      atom.entries[0].score.should == 509.92
    end
    
  end
end
