# This spec was copied and modified from the Hashie gem
# 
# Copyright (c) 2009 Intridea, Inc.
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'spec_helper'
require 'hashie/extensions/coercion'

Hashie::Hash.class_eval do
  def self.inherited(klass)
    klass.instance_variable_set('@inheritance_test', true)
  end
end

class DashTest < FamilySearch::Gedcomx::SuperDash
  property :first_name, :required => true
  property :email
  property :count, :default => 0
end

class DashNoRequiredTest < FamilySearch::Gedcomx::SuperDash
  property :first_name
  property :email
  property :count, :default => 0
end

class Subclassed < DashTest
  property :last_name, :required => true
end

class DashDefaultTest < FamilySearch::Gedcomx::SuperDash
  property :aliases, :default => ["Snake"]
end

class DashCoercionTest < FamilySearch::Gedcomx::SuperDash
  include FamilySearch::Gedcomx::SuperCoercion
  property :dash_test
  coerce_key :dash_test, DashTest
end

class DeferredTest < FamilySearch::Gedcomx::SuperDash
  property :created_at, :default => Proc.new { Time.now }
end

class DashesInArray < FamilySearch::Gedcomx::SuperDash
  include FamilySearch::Gedcomx::SuperCoercion
  property :dash_tests
  property :dash_hash
  coerce_key :dash_tests, [DashTest]
  coerce_key :dash_hash, {'key' => DashTest}
end

describe DashTest do

  subject { DashTest.new(:first_name => 'Bob', :email => 'bob@example.com') }

  it('subclasses Hashie::Hash') { should respond_to(:to_mash) }

  its(:to_s) { should == '#<DashTest count=0 email="bob@example.com" first_name="Bob">' }

  it 'lists all set properties in inspect' do
    subject.first_name = 'Bob'
    subject.email = 'bob@example.com'
    subject.inspect.should == '#<DashTest count=0 email="bob@example.com" first_name="Bob">'
  end

  its(:count) { should be_zero }

  it { should respond_to(:first_name) }
  it { should respond_to(:first_name=) }
  it { should_not respond_to(:nonexistent) }

  it 'does not error out for a non-existent property' do
    lambda { subject['nonexistent'] }.should_not raise_error(NoMethodError)
  end

  it 'errors out when attempting to set a required property to nil' do
    lambda { subject.first_name = nil }.should raise_error(ArgumentError)
  end

  context 'writing to properties' do

    it 'fails writing a required property to nil' do
      lambda { subject.first_name = nil }.should raise_error(ArgumentError)
    end

    it 'fails writing a required property to nil using []=' do
      lambda { subject['first_name'] = nil }.should raise_error(ArgumentError)
    end

    it 'succeeds writing to a non-existent property using []=' do
      lambda { subject['nonexistent'] = 123 }.should_not raise_error(NoMethodError)
    end

    it 'works for an existing property using []=' do
      subject['first_name'] = 'Bob'
      subject['first_name'].should == 'Bob'
      subject[:first_name].should == 'Bob'
    end

    it 'works for an existing property using a method call' do
      subject.first_name = 'Franklin'
      subject.first_name.should == 'Franklin'
    end
  end

  context 'reading from properties' do
    it 'succeeds reading from a non-existent property using []' do
      lambda { subject['nonexistent'] }.should_not raise_error(NoMethodError)
    end

    it "should be able to retrieve properties through blocks" do
      subject["first_name"] = "Aiden"
      value = nil
      subject.[]("first_name") { |v| value = v }
      value.should == "Aiden"
    end

    it "should be able to retrieve properties through blocks with method calls" do
      subject["first_name"] = "Frodo"
      value = nil
      subject.first_name { |v| value = v }
      value.should == "Frodo"
    end
  end

  context 'reading from deferred properties' do
    it 'should evaluate proc after initial read' do
      DeferredTest.new['created_at'].should be_instance_of(Time)
    end

    it "should not evalute proc after subsequent reads" do
      deferred = DeferredTest.new
      deferred['created_at'].object_id.should == deferred['created_at'].object_id
    end
  end

  describe '.new' do
    it 'fails with non-existent properties' do
      lambda { described_class.new(:bork => '') }.should_not raise_error(NoMethodError)
    end

    it 'should set properties that it is able to' do
      obj = described_class.new :first_name => 'Michael'
      obj.first_name.should == 'Michael'
    end

    it 'accepts nil' do
      lambda { DashNoRequiredTest.new(nil) }.should_not raise_error
    end

    it 'accepts block to define a global default' do
      obj = described_class.new { |hash, key| key.to_s.upcase }
      obj.first_name.should == 'FIRST_NAME'
      obj.count.should be_zero
    end

    it "fails when required values are missing" do
      expect { DashTest.new }.to raise_error(ArgumentError)
    end

    it "does not overwrite default values" do
      obj1 = DashDefaultTest.new
      obj1.aliases << "El Rey"
      obj2 = DashDefaultTest.new
      obj2.aliases.should_not include "El Rey"
    end
  end

  describe 'properties' do
    it 'lists defined properties' do
      described_class.properties.should == Set.new([:first_name, :email, :count])
    end

    it 'checks if a property exists' do
      described_class.property?('first_name').should be_true
      described_class.property?(:first_name).should be_true
    end

    it 'checks if a property is required' do
      described_class.required?('first_name').should be_true
      described_class.required?(:first_name).should be_true
    end

    it 'doesnt include property from subclass' do
      described_class.property?(:last_name).should be_false
    end

    it 'lists declared defaults' do
      described_class.defaults.should == { :count => 0 }
    end
  end

  describe '#replace' do
    before { subject.replace(:first_name => "Cain") }

    it 'return self' do
      subject.replace(:email => "bar").to_hash.
        should == {"email" => "bar", "count" => 0}
    end

    it 'sets all specified keys to their corresponding values' do
      subject.first_name.should == "Cain"
    end

    it 'leaves only specified keys and keys with default values' do
      subject.keys.sort.should == ['count', 'first_name']
      subject.email.should be_nil
      subject.count.should == 0
    end

    context 'when replacing keys with default values' do
      before { subject.replace(:count => 3) }

      it 'sets all specified keys to their corresponding values' do
        subject.count.should == 3
      end
    end
  end
end

describe FamilySearch::Gedcomx::SuperDash, 'inheritance' do
  before do
    @top = Class.new(FamilySearch::Gedcomx::SuperDash)
    @middle = Class.new(@top)
    @bottom = Class.new(@middle)
  end

  it 'reports empty properties when nothing defined' do
    @top.properties.should be_empty
    @top.defaults.should be_empty
  end

  it 'inherits properties downwards' do
    @top.property :echo
    @middle.properties.should include(:echo)
    @bottom.properties.should include(:echo)
  end

  it 'doesnt inherit properties upwards' do
    @middle.property :echo
    @top.properties.should_not include(:echo)
    @bottom.properties.should include(:echo)
  end

  it 'allows overriding a default on an existing property' do
    @top.property :echo
    @middle.property :echo, :default => 123
    @bottom.properties.to_a.should == [:echo]
    @bottom.new.echo.should == 123
  end

  it 'allows clearing an existing default' do
    @top.property :echo
    @middle.property :echo, :default => 123
    @bottom.property :echo
    @bottom.properties.to_a.should == [:echo]
    @bottom.new.echo.should be_nil
  end

  it 'should allow nil defaults' do
    @bottom.property :echo, :default => nil
    @bottom.new.should have_key('echo')
  end

end

describe Subclassed do

  subject { Subclassed.new(:first_name => 'Bob', :last_name => 'McNob', :email => 'bob@example.com') }

  its(:count) { should be_zero }

  it { should respond_to(:first_name) }
  it { should respond_to(:first_name=) }
  it { should respond_to(:last_name) }
  it { should respond_to(:last_name=) }

  it 'has one additional property' do
    described_class.property?(:last_name).should be_true
  end

  it "didn't override superclass inheritance logic" do
    described_class.instance_variable_get('@inheritance_test').should be_true
  end

end


describe DashCoercionTest do
  subject { DashCoercionTest.new(:dash_test => {:first_name => 'Bob', :email => 'bob@example.com'}) }
  it "should coerce the properties into its right value" do
    subject.dash_test.should be_instance_of(DashTest)
  end
end

describe DashesInArray do
  subject { DashesInArray.new(:dash_tests => [{:first_name => 'Bob', :email => 'bob@example.com'},{:first_name => 'Bobby', :email => 'bobby@example.com'}], :dash_hash => {'first' => {:first_name => 'Bob', :email => 'bob@example.com'}, 'second' => {:first_name => 'Bobby', :email => 'bobby@example.com'}}) }
  it "should coerce the properties into its right value" do
    subject.dash_tests[0].should be_instance_of(DashTest)
    subject.dash_hash['first'].should be_instance_of(DashTest)
  end
end