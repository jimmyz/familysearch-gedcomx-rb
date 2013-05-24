require 'spec_helper'
require 'json'

describe FamilySearch::Gedcomx::Fact do  
  subject { FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person.json'))) }
  
  describe "distributing place details to the place objects" do
    it 'should have a #normalized on the PlaceReference objects' do
      subject.persons[0].birth.place.normalized.should be_instance_of(FamilySearch::Gedcomx::PlaceDescription)
    end
    
  end
end
