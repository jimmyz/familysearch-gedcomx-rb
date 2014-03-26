require 'spec_helper'
require 'json'

describe FamilySearch::Gedcomx::Graph do
  subject(:graph) { FamilySearch::Gedcomx::Graph.new }
  describe "Initializing" do
    it "should have an array of persons" do
      graph.persons.should be_a_kind_of(Array)
    end

  end

  describe "#<< adding Person objects" do
    before(:each) do
      @familysearch = FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person-with-relationships.json')))
    end

    it "should accept a Person object" do
      graph << @familysearch
    end

    it "should convert the Person object into a GraphPerson" do
      graph << @familysearch
      graph.persons[0].class.should == FamilySearch::Gedcomx::GraphPerson
    end

    it "should assign the Graph object to the GraphPerson instance" do
      graph << @familysearch
      graph.persons[0].graph.should == graph
    end

    it "should be able to retrieve by person ID" do
      graph << @familysearch
      graph.person('L7PD-KY3').id.should == 'L7PD-KY3'
    end

    it "should set the root as the first thing added" do
      graph << @familysearch
      graph.root.id.should == 'L7PD-KY3'
    end

    it "should set a property of childAndParentsRelationships" do
      graph << @familysearch
      graph.childAndParentsRelationships.should == @familysearch.childAndParentsRelationships
    end

    it "should set a property of parent_child_relationships" do
      graph << @familysearch
      graph.parent_child_relationships.should ==
        @familysearch.parent_child_relationships
    end

    it "should set a property of couple_relationships" do
      graph << @familysearch
      graph.couple_relationships.should ==
        @familysearch.couple_relationships
    end

    context "adding multiple people to graph" do
      before(:each) do
        @fs_mother = FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person-with-relationships-mother.json')))
        @fs_father = FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person-with-relationships-father.json')))
        graph << @familysearch
      end

      it "should add the mother and father to the graph and still have the child" do
        graph << @fs_mother
        graph << @fs_father
        graph.persons.size.should == 3
        graph.person('L78M-TD6').id.should == @fs_mother.persons[0].id
        graph.person('L78M-RLN').id.should == @fs_father.persons[0].id
      end

      it "should keep the root as the first person added" do
        graph << @fs_mother
        graph << @fs_father
        graph.root.id.should == @familysearch.persons[0].id
      end

      it "should add the mother's relationships to the childAndParentsRelationships" do
        cpr_ids = graph.childAndParentsRelationships.map(&:id)
        graph << @fs_mother
        graph << @fs_father
        new_cpr_ids = graph.childAndParentsRelationships.map(&:id)
        (new_cpr_ids & cpr_ids).should == cpr_ids
      end

      it "should add the mother's relationships to the couple_relationships" do
        current_cr_ids = graph.couple_relationships.collect{|r|r.id}
        graph << @fs_mother
        graph << @fs_father
        new_cr_ids = graph.couple_relationships.collect{|r|r.id}
        (new_cr_ids & current_cr_ids).should == current_cr_ids
      end

      it "should add the mother's relationships to the parent_child_relationships" do
        current_pcr_ids = graph.parent_child_relationships.map(&:id)
        graph << @fs_mother
        graph << @fs_father
        new_pcr_ids = graph.parent_child_relationships.map(&:id)
        (new_pcr_ids & current_pcr_ids).should == current_pcr_ids
      end

      it "should not do anything if you add the same person twice" do
        graph << @fs_mother
        b4_size = graph.persons.size
        b4_cpr_ids = graph.childAndParentsRelationships.map(&:id)
        b4_cr_ids = graph.couple_relationships.map(&:id)
        b4_pcr_ids = graph.parent_child_relationships.map(&:id)
        graph << @fs_mother
        graph.persons.size.should == b4_size
        graph.childAndParentsRelationships.map(&:id).should == b4_cpr_ids
        graph.couple_relationships.map(&:id).should == b4_cr_ids
        graph.parent_child_relationships.map(&:id) == b4_pcr_ids
      end
    end
  end
end
