require 'spec_helper'
require 'json'

describe FamilySearch::Gedcomx::Fact do  
  subject { FamilySearch::Gedcomx::FamilySearch.new(JSON.parse(File.read('spec/familysearch/gedcomx/fixtures/person.json'))) }
  
end
