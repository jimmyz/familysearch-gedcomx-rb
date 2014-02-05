require 'spec_helper'
require 'json'

describe FamilySearch::Gedcomx::Fact do  
  subject { FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person.json'))).persons[0].facts[0] }
  
  context "convenience methods" do
    describe "#date" do
      it 'should be of type FamilySearch::Gedcomx::Date' do
        subject.date.should be_instance_of FamilySearch::Gedcomx::Date
      end
      
      it "should have a #normalized method" do
        subject.date.normalized[0].value.should == "20 June 1834"
      end
      
      it "should have an #original method" do
        subject.date.original.should == "20 Jun 1834"
      end
    end
    
    describe "#place" do
      it "should be of type FamilySearch::Gedcomx::PlaceReference" do
        subject.place.should be_instance_of(FamilySearch::Gedcomx::PlaceReference)
      end
      
      it "should have a #normalized method" do
        subject.place.normalized[0].should be_instance_of(FamilySearch::Gedcomx::TextValue)
      end
      
      it "should have a #normalized.value convenience method" do
        subject.place.normalized[0].value.should == "Lowell, Middlesex, Massachusetts, United States"
      end
      
      it "should have an #original method" do
        subject.place.original.should == "Lowell,Middlx,Mass"
      end
    end  
  end
end
