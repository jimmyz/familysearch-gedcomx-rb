require 'spec_helper'
require 'json'

describe FamilySearch::Gedcomx::GraphPerson do    
  before(:each) do
    @child = FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person-with-relationships.json')))
    @father = FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person-with-relationships-father.json')))
    @mother = FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person-with-relationships-mother.json')))
    @graph = FamilySearch::Gedcomx::Graph.new
    @graph << @child
    @graph << @father
    @graph << @mother
    @graph_person = @graph.root
  end
  
  it "should be setup correctly" do
    @child.should be_instance_of(FamilySearch::Gedcomx::FamilySearch)
    @graph.should be_instance_of(FamilySearch::Gedcomx::Graph)
    @graph.persons.size.should == 3
    @graph_person.id.should == @child.persons[0].id
  end
  
  describe "#father_id" do
    it "should return the id of the father from the first childAndParentsRelationships" do
      @graph_person.father_id.should == 'L78M-RLN'
    end
    
    it "should return nil if any of the values are nil" do
      # Create the relationship to where the father is missing
      cpr = @graph.childAndParentsRelationships.find{|cpr|cpr.child.resourceId == @graph_person.id}
      cpr.father = nil
      @graph_person.father_id.should be_nil
      
      @graph.childAndParentsRelationships = []
      @graph_person.father_id.should be_nil
    end
  end
  
  describe "#mother_id" do
    it "should return the id of the mother from the first childAndParentsRelationships" do
      @graph_person.mother_id.should == 'L78M-TD6'
    end
    
    it "should return nil if any of the values are nil" do
      # Create the relationship to where the father is missing
      cpr = @graph.childAndParentsRelationships.find{|cpr|cpr.child.resourceId == @graph_person.id}
      cpr.mother = nil
      @graph_person.mother_id.should be_nil
      
      @graph.childAndParentsRelationships = []
      @graph_person.mother_id.should be_nil
    end
  end
  
  describe "#father" do
    it "should return a GraphPerson" do
      @graph_person.father.should be_instance_of(FamilySearch::Gedcomx::GraphPerson)
    end
    
    it "should return the father's person" do
      @graph_person.father.id.should == 'L78M-RLN'
    end
    
    it "should return nil if the person hasn't been loaded yet" do
      @graph_person.father.father_id.should_not be_nil
      @graph_person.father.father.should be_nil
    end
    
    it "should return nil if the father_id is nil" do
      @graph_person.stub!(:father_id).and_return(nil)
      @graph_person.father.should be_nil
    end
    
  end
  
  describe "#mother" do
    it "should return a GraphPerson" do
      @graph_person.mother.should be_instance_of(FamilySearch::Gedcomx::GraphPerson)
    end
    
    it "should return the mother's person" do
      @graph_person.mother.id.should == 'L78M-TD6'
    end
    
    it "should return nil if the person hasn't been loaded yet" do
      @graph_person.mother.mother_id.should_not be_nil
      @graph_person.mother.mother.should be_nil
    end
    
    it "should return nil if the father_id is nil" do
      @graph_person.stub!(:mother_id).and_return(nil)
      @graph_person.mother.should be_nil
    end
    
  end
  
end
