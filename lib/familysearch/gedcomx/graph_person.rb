require "familysearch/gedcomx/graph_parents"

module FamilySearch
  module Gedcomx
    class GraphPerson < Person
      attr_accessor :graph
      def initialize(hash,graph = nil)
        super(hash)
        self.graph = graph
      end

      def parent_ids
        relationships_with_parents =
          self.graph.parent_child_relationships.
          select{|r| r.person2.resourceId == self.id}
        relationships_with_parents.map{|r| r.person1.resourceId}
      end

      def father_id
        child_of = self.graph.childAndParentsRelationships.find{|cpr|cpr.child.resourceId == self.id}
        if child_of && child_of.father
          child_of.father.resourceId
        end
      end

      def mother_id
        child_of = self.graph.childAndParentsRelationships.find{|cpr|cpr.child.resourceId == self.id}
        if child_of && child_of.mother
          child_of.mother.resourceId
        end
      end

      def father
        self.graph.person(father_id)
      end

      def mother
        self.graph.person(mother_id)
      end

      def all_parents
        @all_parents ||= get_all_parents
      end

      private

      def get_all_parents
        caprs = self.graph.childAndParentsRelationships.select{|cpr|cpr.child.resourceId == self.id}
        all_parents = caprs.collect do |capr|
          GraphParents.new(capr,self.graph)
        end
        all_parents
      end

    end
  end
end
