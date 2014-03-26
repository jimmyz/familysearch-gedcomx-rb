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
    @root = @graph.root
  end

  it "should be setup correctly" do
    @child.should be_instance_of(FamilySearch::Gedcomx::FamilySearch)
    @graph.should be_instance_of(FamilySearch::Gedcomx::Graph)
    @graph.persons.size.should == 3
    @root.id.should == @child.persons[0].id
  end

  describe "#father_id" do
    it "should return the id of the father from the first childAndParentsRelationships" do
      @root.father_id.should == 'L78M-RLN'
    end

    it "should return nil if any of the values are nil" do
      # Create the relationship to where the father is missing
      cpr = @graph.childAndParentsRelationships.find{|cpr|cpr.child.resourceId == @root.id}
      cpr.father = nil
      @root.father_id.should be_nil

      @graph.childAndParentsRelationships = []
      @root.father_id.should be_nil
    end
  end

  describe "#mother_id" do
    it "should return the id of the mother from the first childAndParentsRelationships" do
      @root.mother_id.should == 'L78M-TD6'
    end

    it "should return nil if any of the values are nil" do
      # Create the relationship to where the father is missing
      cpr = @graph.childAndParentsRelationships.find{|cpr|cpr.child.resourceId == @root.id}
      cpr.mother = nil
      @root.mother_id.should be_nil

      @graph.childAndParentsRelationships = []
      @root.mother_id.should be_nil
    end
  end

  describe "#father" do
    it "should return a GraphPerson" do
      @root.father.should be_instance_of(FamilySearch::Gedcomx::GraphPerson)
    end

    it "should return the father's person" do
      @root.father.id.should == 'L78M-RLN'
    end

    it "should return nil if the person hasn't been loaded yet" do
      @root.father.father_id.should_not be_nil
      @root.father.father.should be_nil
    end

    it "should return nil if the father_id is nil" do
      @root.stub!(:father_id).and_return(nil)
      @root.father.should be_nil
    end

  end

  describe "#mother" do
    it "should return a GraphPerson" do
      @root.mother.should be_instance_of(FamilySearch::Gedcomx::GraphPerson)
    end

    it "should return the mother's person" do
      @root.mother.id.should == 'L78M-TD6'
    end

    it "should return nil if the person hasn't been loaded yet" do
      @root.mother.mother_id.should_not be_nil
      @root.mother.mother.should be_nil
    end

    it "should return nil if the father_id is nil" do
      @root.stub!(:mother_id).and_return(nil)
      @root.mother.should be_nil
    end

  end

  describe "#all_parents" do
    it "should return an array of GraphParents objects" do
      @root.all_parents[0].class.should == FamilySearch::Gedcomx::GraphParents
    end

    it "should allow me to get to the father, mother, and child of the relationship" do
      @root.all_parents[0].father.class.should == FamilySearch::Gedcomx::GraphPerson
      @root.all_parents[0].mother.class.should == FamilySearch::Gedcomx::GraphPerson
      @root.all_parents[0].child.class.should == FamilySearch::Gedcomx::GraphPerson
    end

    it "should return the right person" do
      @root.all_parents[0].father.should == @root.father
      @root.all_parents[0].mother.should == @root.mother
      @root.all_parents[0].child.should == @root
    end
  end

end
