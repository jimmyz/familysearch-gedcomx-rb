require 'spec_helper'
require 'json'

describe FamilySearch::Gedcomx::Person do  
  subject { FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person.json'))).persons[0] }
  
  context "convenience methods" do
    describe "#name" do
      it 'should provide the first names array ' do
        subject.name.class.should == FamilySearch::Gedcomx::Name
      end
      
      it "should return nil if names array is empty or nil" do
        subject.names = []
        subject.name.should == nil
        subject.names = nil
        subject.name.should == nil
      end
      
      it "should have a fullText that defaults to the first nameForm's fullText" do
        subject.name.fullText.should == "Marshall P Felch"
      end
      
      it "should return \"\" if anything in the path is nil" do
        subject.names[0].nameForms = nil
        subject.name.fullText.should == ""
        subject.names[0].nameForms = []
        subject.name.fullText.should == ""
      end
    end
    
    describe "#full_name" do
      it "should return the first name's first nameForm's fullText" do
        subject.full_name.should == "Marshall P Felch"
      end
      
      it "should return '' if there are no names" do
        subject.names = []
        subject.full_name.should == ''
        subject.names = nil
        subject.full_name.should == ''
      end
    end
    
    describe "#surname" do
      it "should return the surname of the first name's first nameForm" do
        subject.surname.should == "Felch"
      end
      
      it "should return '' if there is a nil anywhere in the process" do
        subject.names[0].nameForms[0].parts = []
        subject.surname.should == ''
        subject.names[0].nameForms[0].parts = nil
        subject.surname.should == ''
        subject.names[0].nameForms = []
        subject.surname.should == ''
        subject.names[0].nameForms = nil
        subject.surname.should == ''
        subject.names= []
        subject.surname.should == ''
        subject.names= nil
        subject.surname.should == ''
      end
    end
    
    describe "#given_name" do
      it "should return the surname of the first name's first nameForm" do
        subject.given_name.should == "Marshall P"
      end
      
      it "should return '' if there is a nil anywhere in the process" do
        subject.names[0].nameForms[0].parts = []
        subject.given_name.should == ''
        subject.names[0].nameForms[0].parts = nil
        subject.given_name.should == ''
        subject.names[0].nameForms = []
        subject.given_name.should == ''
        subject.names[0].nameForms = nil
        subject.given_name.should == ''
        subject.names= []
        subject.given_name.should == ''
        subject.names= nil
        subject.given_name.should == ''
      end
    end
    
    
    describe "#id" do
      it "should return the person's id" do
        subject.id.should == "L7PD-KY3"
      end
    end
    
    describe "#birth" do
      it "should return the person's first birth event" do
        subject.birth.class.should == FamilySearch::Gedcomx::Fact
      end
      
      it "should return nil if there is no birth event" do
        subject.birth.type = "http://gedcomx.org/SomethingElse"
        subject.birth.should == nil
      end
      
      it "should return nil if there are no facts" do
        subject.facts = []
        subject.birth.should == nil
        subject.facts = nil
        subject.birth.should == nil
      end      
    end
    
    describe "#death" do
      it "should return the person's first death event" do
        subject.death.class.should == FamilySearch::Gedcomx::Fact
      end
      
      it "should have the type of http://gedcomx.org/Death" do
        subject.death.type.should == "http://gedcomx.org/Death"
      end
      
      it "should return nil if there is no birth event" do
        subject.death.type = "http://gedcomx.org/SomethingElse"
        subject.death.should == nil
      end
      
      it "should return nil if there are no facts" do
        subject.facts = []
        subject.death.should == nil
        subject.facts = nil
        subject.death.should == nil
      end
    end
    
    describe "#christening" do
      it "should return the person's first christening event" do
        subject.christening.class.should == FamilySearch::Gedcomx::Fact
      end
      
      it "should have the type of http://gedcomx.org/Christening" do
        subject.christening.type.should == "http://gedcomx.org/Christening"
      end
      
      it "should return nil if there is no birth event" do
        subject.christening.type = "http://gedcomx.org/SomethingElse"
        subject.christening.should == nil
      end
      
      it "should return nil if there are no facts" do
        subject.facts = []
        subject.christening.should == nil
        subject.facts = nil
        subject.christening.should == nil
      end
    end
    
    describe "#burial" do
      it "should return the person's first death event" do
        subject.burial.class.should == FamilySearch::Gedcomx::Fact
      end
      
      it "should have the type of http://gedcomx.org/Burial" do
        subject.burial.type.should == "http://gedcomx.org/Burial"
      end
      
      it "should return nil if there is no birth event" do
        subject.burial.type = "http://gedcomx.org/SomethingElse"
        subject.burial.should == nil
      end
      
      it "should return nil if there are no facts" do
        subject.facts = []
        subject.burial.should == nil
        subject.facts = nil
        subject.burial.should == nil
      end
    end
  end
end
