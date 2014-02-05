module FamilySearch
  module Gedcomx
    class ExtensibleData < SuperDash
      include SuperCoercion
      property :id
    end    

    class Link < SuperDash
      property :hreflang
      property :template
      property :title
      property :allow
      property :accept
      property :rel
      property :type
      property :href
    end
    
    class HypermediaEnabledData < ExtensibleData
      property :links
      coerce_key :links, {'key' => Link}
    end
    
    class ResourceReference < SuperDash
      property :resourceId
      property :resource
    end
        
    class Address < ExtensibleData
      property :city
      property :country
      property :postalCode
      property :stateOrProvince
      property :street
      property :street2
      property :street3
      property :value
    end
    
    class OnlineAccount < ExtensibleData
      property :accountName
      property :serviceHomepage
      coerce_key :serviceHomepage, [ResourceReference]
    end

    class Identifier < SuperDash
      property :type
      property :value
    end

    class TextValue < SuperDash
      property :lang
      property :value
    end
        
    class Agent < HypermediaEnabledData
      property :accounts
      property :addresses
      property :emails
      property :homepage
      property :identifiers
      property :names
      property :openid
      property :phones
      coerce_key :accounts, [OnlineAccount]
      coerce_key :addresses, [Address]
      coerce_key :emails, [ResourceReference]
      coerce_key :homepage, [ResourceReference]
      coerce_key :identifiers, [Identifier]
      coerce_key :names, [TextValue]
      coerce_key :openid, ResourceReference
      coerce_key :phones, [ResourceReference]
    end
    
    class Attribution < ExtensibleData
      property :contributor
      property :modified
      property :changeMessage
      coerce_key :contributor, ResourceReference
    end
    
    class ChangeInfo < SuperDash
      property :objectModifier
      property :operation
      property :reason
      property :parent
      property :objectType
    end

    class Qualifier < SuperDash
      property :value
    end
    
    class SourceReference < HypermediaEnabledData
      property :description
      property :resource
      property :attribution
      property :qualifiers

      coerce_key :attribution, Attribution
      coerce_key :qualifiers, [Qualifier]
    end
    
    class Note < HypermediaEnabledData
      property :lang
      property :subject
      property :text
      property :attribution
      coerce_key :attribution, Attribution
    end
    
    class Conclusion < HypermediaEnabledData
      property :confidence
      property :lang
      property :attribution
      property :sources
      property :analysis
      property :notes
      coerce_key :attribution, Attribution
      coerce_key :sources, [SourceReference]
      coerce_key :analysis, [ResourceReference]
      coerce_key :notes, [Note]
    end

    class EvidenceReference < HypermediaEnabledData
      property :resourceId
      property :resource
      property :analysis
      property :attribution
      coerce_key :analysis, ResourceReference
      coerce_key :attribution, Attribution
    end
    
    class PlaceReference < ExtensibleData
      property :description
      property :field
      property :original      
      coerce_key :field, EvidenceReference
      property :normalized
      coerce_key :normalized, [TextValue]
    end
    
    class Date < ExtensibleData
      property :original
      property :formal
      property :normalized
      property :field
      coerce_key :normalized, [TextValue]
      coerce_key :field, EvidenceReference
    end
    
    class Fact < Conclusion
      property :type
      property :date
      property :place
      property :value
      property :qualifiers
      property :field
      coerce_key :date, FamilySearch::Gedcomx::Date
      coerce_key :place, PlaceReference
      coerce_key :qualifiers, [Qualifier]
      coerce_key :field, EvidenceReference
    end
    
    class ChildAndParentsRelationship < Conclusion
      property :father
      property :mother
      property :child
      property :fatherFacts
      property :motherFacts
      coerce_key :father, ResourceReference
      coerce_key :mother, ResourceReference
      coerce_key :child, ResourceReference
      coerce_key :fatherFacts, [Fact]
      coerce_key :motherFacts, [Fact]
    end
    
    class CitationField <SuperDash
      property :name
      property :value
    end

    class CollectionCoverage < HypermediaEnabledData
      property :completeness
      property :count
      property :recordType
      property :resourceType
      property :spatial
      property :temporal
      coerce_key :spatial, PlaceReference
      coerce_key :temporal, FamilySearch::Gedcomx::Date
    end

    class FacetValue < HypermediaEnabledData
      property :title
      property :value
      property :count
    end
    
    class Facet < HypermediaEnabledData
      property :type
      property :title
      property :key
      property :facets
      property :values
      coerce_key :facets, [Facet]
      coerce_key :values, [FacetValue]
    end
    
    class Collection < HypermediaEnabledData
      property :lang
      property :title
      property :description
      property :collection
      property :size
      property :coverage
      property :facets
      property :attribution
      coerce_key :collection, ResourceReference
      coerce_key :coverage, CollectionCoverage
      coerce_key :facets, [Facet]
      coerce_key :attribution, Attribution
    end
    
    class Comment < HypermediaEnabledData
      property :text
      property :created
      property :contributor
      coerce_key :contributor, ResourceReference
    end
    
    class Discussion < HypermediaEnabledData
      property :title
      property :details
      property :created
      property :contributor
      property :modified
      property :numberOfComments
      property :comments
      coerce_key :contributor, ResourceReference
      coerce_key :comments, [Comment]
    end
    
    class DiscussionReference < HypermediaEnabledData
      property :resource
    end
    
    class DisplayProperties < ExtensibleData
      property :ascendancyNumber
      property :birthDate
      property :birthPlace
      property :deathDate
      property :deathPlace
      property :descendancyNumber
      property :gender
      property :lifespan
      property :name
    end
    
    class Document < Conclusion
      property :textType
      property :extracted
      property :type
      property :text
    end
    
    class Error < SuperDash
      property :code
      property :label
      property :message
      property :stacktrace
    end

    class Subject < Conclusion
      property :extracted
      property :evidence
      property :media
      property :identifiers
      
      coerce_key :evidence, [EvidenceReference]
      coerce_key :media, [SourceReference]
      # coerce_key :identifiers, [Identifier]
    end
        
    class EventRole < Conclusion
      property :type
      property :person
      property :details
      coerce_key :person, ResourceReference
    end
        
    class Event < Subject
      property :type
      property :date
      property :place
      property :roles
      coerce_key :date, FamilySearch::Gedcomx::Date
      coerce_key :place, PlaceReference
      coerce_key :roles, [EventRole]
    end
    
    class Gender < Conclusion
      property :type
      property :field
      coerce_key :field, EvidenceReference
    end
    
    class NamePart < ExtensibleData
      property :value
      property :type
      property :field
      property :qualifiers
      
      coerce_key :field, EvidenceReference
      coerce_key :qualifiers, [Qualifier]
    end
    
    class NameForm < ExtensibleData
      property :lang
      property :fullText
      property :parts
      property :field
      
      coerce_key :parts, [NamePart]
      coerce_key :field, EvidenceReference
      
      def surname
        return '' if parts.nil?
        surname_piece = parts.find{|p|p.type == 'http://gedcomx.org/Surname'}
        surname_piece ? surname_piece.value : ''
      end
      
      def given_name
        return '' if parts.nil?
        given_piece = parts.find{|p|p.type == 'http://gedcomx.org/Given'}
        given_piece ? given_piece.value : ''
      end
      
    end

    class Name < Conclusion
      property :type
      property :preferred
      property :date
      property :nameForms
      coerce_key :date, FamilySearch::Gedcomx::Date
      coerce_key :nameForms, [NameForm]  
      
      def fullText
        (nameForms && nameForms[0]) ? nameForms[0].fullText : ""
      end
      
      def surname
        (nameForms && nameForms[0]) ? nameForms[0].surname : ""
      end
      
      def given_name
        (nameForms && nameForms[0]) ? nameForms[0].given_name : ""
      end
      
    end
    
    class Person < Subject
      property :collection
      property :living
      property :gender
      property :names
      property :facts
      property :display
      
      coerce_key :gender, Gender
      coerce_key :names, [Name]
      coerce_key :facts, [Fact]
      coerce_key :display, DisplayProperties
      
      # Returns the first name in the names array
      def name
        names[0] if names
      end
      
      def full_name
        (name) ? name.fullText : ''
      end
      
      def surname
        (name) ? name.surname : ''
      end
      
      def given_name
        (name) ? name.given_name : ''
      end
      
      def birth
        facts.find{|f|f.type == "http://gedcomx.org/Birth"} if facts
      end
      
      def death
        facts.find{|f|f.type == "http://gedcomx.org/Death"} if facts
      end
      
      def christening
        facts.find{|f|f.type == "http://gedcomx.org/Christening"} if facts
      end
      
      def burial
        facts.find{|f|f.type == "http://gedcomx.org/Burial"} if facts
      end
    end
    
    class Relationship < Subject
      property :type
      property :person1
      property :person2
      property :facts
      property :field
      coerce_key :person1, ResourceReference
      coerce_key :person2, ResourceReference
      coerce_key :facts, [Fact]
      coerce_key :field, EvidenceReference
    end
    
    class SourceCitation < HypermediaEnabledData
      property :lang
      property :citationTemplate
      property :fields
      property :value
      
      coerce_key :citationTemplate, ResourceReference
      coerce_key :fields, [CitationField]
    end
    
    class SourceDescription < HypermediaEnabledData
      property :about
      property :mediaType
      property :resourceType
      property :citations
      property :mediator
      property :sources
      property :analysis
      property :componentOf
      property :titles
      property :notes
      property :attribution
      
      coerce_key :citations, [SourceCitation]
      coerce_key :mediator, ResourceReference
      coerce_key :sources, [SourceReference]
      coerce_key :analysis, ResourceReference
      coerce_key :componentOf, SourceReference
      coerce_key :titles, [TextValue]
      coerce_key :notes, [Note]
      coerce_key :attribution, Attribution
    end
    
    class PlaceDescription < Subject
      property :type
      property :names
      property :temporalDescription
      property :latitude
      property :longitude
      property :spatialDescription
      coerce_key :names, [TextValue]
      coerce_key :temporalDescription, FamilySearch::Gedcomx::Date
      coerce_key :spatialDescription, ResourceReference
      
      def value
        names[0].value if names
      end
    end
    
    class FieldValue < Conclusion
      property :resource
      property :datatype
      property :type
      property :interpretationSources
      property :text
      coerce_key :interpretationSources, [ResourceReference]
    end
    
    class Field < HypermediaEnabledData
      property :type
      property :label
      property :values
      coerce_key :values, [FieldValue]
    end
    
    class Record < HypermediaEnabledData
      property :type
      property :sources
      property :identifiers
      property :principalPersons
      property :primaryEvent
      property :collection
      property :descriptor
      property :fields
      property :notes
      property :attribution
      coerce_key :sources, [SourceReference]
      coerce_key :identifiers, [Identifier]
      coerce_key :principalPersons, [ResourceReference]
      coerce_key :primaryEvent, ResourceReference
      coerce_key :collection, ResourceReference
      coerce_key :descriptor, ResourceReference
      coerce_key :fields, [Field]
      coerce_key :notes, [Note]
      coerce_key :attribution, Attribution
    end
    
    class FieldDescriptor < SuperDash
      property :displayOriginalValue
      property :description
      property :displayLabel
      property :originalLabel
      property :systemLabel
    end
    
    class RecordDescriptor < HypermediaEnabledData
      property :lang
      property :fields
      coerce_key :fields, [FieldDescriptor]
    end
    
    class Gedcomx < HypermediaEnabledData
      property :lang
      property :attribution
      property :persons
      property :relationships
      property :sourceDescriptions
      property :agents
      property :events
      property :places
      property :documents
      property :collections
      property :records
      property :recordDescriptors
      coerce_key :attribution, Attribution
      coerce_key :persons, [Person]
      coerce_key :relationships, [Relationship]
      coerce_key :sourceDescriptions, [SourceDescription]
      coerce_key :agents, [Agent]
      coerce_key :events, [Event]
      coerce_key :places, [PlaceDescription]
      coerce_key :documents, [Document]
      coerce_key :collections, [Collection]
      coerce_key :records, [Record]
      coerce_key :recordDescriptors, [RecordDescriptor]
    end
    
    class User < HypermediaEnabledData
      property :alternateEmail
      property :birthDate
      property :contactName
      property :country
      property :displayName
      property :email
      property :familyName
      property :fullName
      property :gender
      property :givenName
      property :helperAccessPin
      property :id
      property :ldsMemberAccount
      property :mailingAddress
      property :personId
      property :phoneNumber
      property :preferredLanguage
      property :treeUserId
    end    
    
    class Merge < SuperDash
      include SuperCoercion
      property :resourcesToDelete
      property :resourcesToCopy
      coerce_key :resourcesToDelete, [ResourceReference]
      coerce_key :resourcesToCopy, [ResourceReference]
    end
    
    class MergeConflict < SuperDash
      include SuperCoercion
      property :survivorResource
      property :duplicateResource
      coerce_key :survivorResource, ResourceReference
      coerce_key :duplicateResource, ResourceReference
    end
    
    class MergeAnalysis < SuperDash
      include SuperCoercion
      property :survivorResources
      property :duplicateResources
      property :conflictingResources
      property :survivor
      property :duplicate

      coerce_key :survivorResources, [ResourceReference]
      coerce_key :duplicateResources, [ResourceReference]
      coerce_key :conflictingResources, [MergeConflict]
      coerce_key :survivor, ResourceReference
      coerce_key :duplicate, ResourceReference
    end
    
    class FamilySearch < Gedcomx
      property :childAndParentsRelationships
      property :discussions
      property :users
      property :merges
      property :mergeAnalyses
      coerce_key :childAndParentsRelationships, [ChildAndParentsRelationship]
      coerce_key :discussions, [Discussion]
      coerce_key :users, [User]
      coerce_key :merges, [Merge]
      coerce_key :mergeAnalyses, [MergeAnalysis]
      
      def initialize(args)
        super(args)
      end
      
      private
            
      def find_place_references(hash_obj)
        place_references = []
        hash_obj.each do |k,v|
          if v.class == PlaceReference
            place_references << v
          elsif v.class == Array
            v.each do |obj|
              place_references += find_place_references(obj) if obj.kind_of? Hash
            end
          elsif v.kind_of? Hash
            place_references += find_place_references(v)
          end
        end
        return place_references
      end
    end
    
    class HealthConfig < SuperDash
      property :buildDate
      property :buildVersion
      property :databaseVersion
      property :platformVersion
    end
        
    class Tag < SuperDash
      property :resource
    end
    
    class AtomCommonAttributes < SuperDash
      property :base
      property :lang
    end
    
    class AtomExtensibleElement < AtomCommonAttributes
      include SuperCoercion
    end
    
    class AtomPerson < AtomExtensibleElement
      property :name
      property :uri
      property :email
    end
    
    class AtomGenerator < SuperDash
      property :base
      property :uri
      property :lang
      property :version
      property :value
    end
    
    class AtomCategory < AtomCommonAttributes
      property :scheme
      property :term
      property :label
    end
    
    class AtomContent < SuperDash
      include SuperCoercion
      property :type
      property :gedcomx
      
      coerce_key :gedcomx, Gedcomx
    end
    
    class AtomEntry < AtomExtensibleElement
      property :authors
      property :categories
      property :confidence
      property :content
      property :contributors
      property :id
      property :links
      property :published
      property :rights
      property :score
      property :title
      property :updated
      
      coerce_key :authors, [AtomPerson]
      coerce_key :categories, [AtomCategory]
      coerce_key :content, AtomContent
      coerce_key :contributors, [AtomPerson]
      coerce_key :links, {'key' => Link}
    end
    
    class AtomFeed < AtomExtensibleElement
      property :authors
      property :contributors
      property :generator
      property :icon
      property :id
      property :results
      property :index
      property :links
      property :logo
      property :rights
      property :subtitle
      property :title
      property :updated
      property :entries
      property :facets
      
      coerce_key :authors, [AtomPerson]
      coerce_key :contributors, [AtomPerson]
      coerce_key :generator, AtomGenerator
      coerce_key :links, {'key' => Link}
      coerce_key :entries, [AtomEntry]
      coerce_key :facets, [Facet]
    end
  end
end
