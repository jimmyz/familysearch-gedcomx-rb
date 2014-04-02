require "familysearch/gedcomx/graph_person"
module FamilySearch
  module Gedcomx

    # The Graph takes a collection of objects and stitches persons together
    # so that you can walk around the graph to different relationships.
    class Graph
      attr_accessor :root
      attr_accessor :persons
      attr_accessor :person_index
      attr_accessor :couple_relationships
      attr_accessor :parent_child_relationships
      attr_accessor :childAndParentsRelationships

      def initialize()
        self.persons = []
        self.person_index = {}
        self.childAndParentsRelationships = []
        self.parent_child_relationships = []
        self.couple_relationships = []
      end

      def << (familysearch)
        person = familysearch.persons[0]
        # only add the person if it hasn't already been added
        if !self.person_index[person.id]
          graph_person = GraphPerson.new(person,self)
          self.persons << graph_person
          self.person_index[person.id] = graph_person
          self.root ||= graph_person

          # Update relationships hash
          update_cpr(familysearch)
          update_cr(familysearch)
          update_pcr(familysearch)
        end
      end

      def person(id)
        self.person_index[id]
      end

      private

      def update_relationships(familysearch, type)
        current_relationships = self.send("#{type}_relationships")
        new_relationships =
          (current_relationships + familysearch.send("#{type}_relationships")).uniq
        self.send("#{type}_relationships=", new_relationships)
      end

      def update_cpr(familysearch)
        current_cpr = self.childAndParentsRelationships
        fs_cpr = familysearch.childAndParentsRelationships || []
        new_cpr = (current_cpr + fs_cpr).uniq
        self.childAndParentsRelationships = new_cpr
      end

      def update_cr(familysearch)
        update_relationships(familysearch, :couple)
      end

      def update_pcr(familysearch)
        update_relationships(familysearch, :parent_child)
      end
    end
  end
end
