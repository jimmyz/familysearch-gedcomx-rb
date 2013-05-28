# FamilySearch::Gedcomx

This familysearch gem extension provides a structured data model for the application/x-fs-v1+json media type.

## Installation

Add this line to your application's Gemfile:

    gem 'familysearch-gedcomx'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install familysearch-gedcomx

*Note:* If you install the familysearch gem, this gem will automatically be installed by virtue of gem dependency.

## Basic Usage

The FamilySearch API returns the application/x-fs-v1+json media type, which would be parsed into a Hash by any JSON parser. In the following usage examples, we will assume that we already have a Hash named fs_hash, which was parsed from the JSON.

    familysearch = FamilySearch::Gedcomx::FamilySearch.new fs_hash
    person = familysearch.persons[0] #=> FamilySearch::Gedcomx::Person object

If you are using the familysearch gem, the data returned from the client should already be a fa

## Convenience Methods

Convenience methods have been added to the Person object to help you access data buried deep into the person data model.
 
	person.full_name 
		#=> "Marshall P Felch"
	person.surname 
		#=> "Felch"
	person.given_name 
		#=> "Marshall P"

### Vital Information

To access the vital events, the following methods have been created to make it easier to jump to the birth information.

	person.birth 
	person.christening
	person.death
	person.burial

In the Gedcomx data model, standardized place information is not found within the Fact, but rather are found in a separate collection of places at the root of the FamilySearch object. This can be difficult to access, so as a convenience, when a FamilySearch::Gedcomx::FamilySearch object is parsed, it connects the PlaceReference to the PlaceDescription. This allows you to do the following.

	person.birth.place.normalized.value
		# => "Middlesex, Massachusetts, United States"

## Traversing the Full Data Model

You can traverse the plain Gedcomx data model to get further details about names, facts, relationships, places, etc. Anything that appears in the underlying JSON should be retrievable via the data model objects.

	person.facts.find{|f|f.type == "http://gedcomx.org/Birth"}.date.original
	person.names.each do |name|
		puts name.confidence #=> "http://gedcomx.org/Low"
		puts name.attribution.contributor.resource #=> "https://familysearch.org/platform/users/agents/MMMM-MM8"
		puts name.type #=> "http://gedcomx.org/BirthName"
		name.nameForms.each do |form|
			puts form.fullText
			form.parts.each do |part|
				puts part.type #=> "http://gedcomx.org/Surname" 
					#=> or "http://gedcomx.org/Given"
				puts part.value
			end
		end
	end
	
You can browse the entire data model schema in the lib/familysearch/gedcomx/data_model.rb file.
### Objects are Hashes

Each object ultimately inherits from Hash and all of their attributes are stored as hash values. The methods, like #name or #name= simply map to the underlying ['name'] hash value. If desired, you can traverse the structures via Hash key access notations:

	person['facts'].find{|f|f['type'] == 'http://gedcomx.org/Birth'}['date']['original'] 
		#=> 'Jun 1834'
	person['display']['gender'] #=> 'Male'

One major advantage of using a Hash-like structure for the data model objects is with JSON serialization. You simply pass the FamilySearch::Gedcomx::FamilySearch object to a JSON serializer and it will serialize the Hash appropriately.

## Graph (Pedigree) Traversal

Many API use cases involve displaying family ancestral pedigrees. This gem provides a mechanism for connecting objects and traversing the graph. To take advantage of this, make persons-with-relationships requests and throw the result into a Graph object.

	graph = FamilySearch::Gedcomx::Graph.new
	
	# Get persons with relationships
	familysearch_child = client.template('person-with-relationships').get({'person' => 'KWQS-BBQ'}).body
	
	graph << familysearch_child
	graph.root #=> the person of the object you just pushed into the graph
	father_id = graph.root.father_id
	
	familysearch_father = client.template('person-with-relationships').get({'person' => father_id}).body
	
	graph << familysearch_father
	
	graph.root.father #=> person object of the father you just pushed into the graph
	

## Versioning

The major version of this gem will match the current value of the application/x-fs-v1+json media type. If the FamilySearch API bumps this to x-fs-v2+json, there should be a version of the gem released to match that version.

Minor version updates should indicate a potential break in backwards compatibility. If a new feature is introduced in this library that will potentially break a client relying on a "~> 1.0.0" dependency, then the minor version will be incremented.

Any other versions that introduce new features that are backwards compatible, will bump the patch number (1.0.1).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
