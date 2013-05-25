module FamilySearch
  module Gedcomx
    class GraphParents
      attr_accessor :capr
      attr_accessor :graph
      def initialize(capr, graph)
        # childAndParentsRelationship
        self.capr = capr
        self.graph = graph
      end      
      
      def father
        self.graph.person(self.capr.father.resourceId) if self.capr.father
      end
      
      def mother
        self.graph.person(self.capr.mother.resourceId) if self.capr.mother
      end
      
      def child
        self.graph.person(self.capr.child.resourceId) if self.capr.child
      end
    end
  end
end