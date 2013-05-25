module FamilySearch
  module Gedcomx
    class GraphPerson < Person
      attr_accessor :graph
      def initialize(hash,graph = nil)
        super(hash)
        self.graph = graph
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
      
    end
  end
end