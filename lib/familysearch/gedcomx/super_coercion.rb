# Significant portions of this code was copied and modified from the Hashie gem
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

# 
module FamilySearch
  module Gedcomx
    # This is basically the Hashie::Extensions::Coercion module, but
    # this needed to be able to support things like this:
    # 
    #     coerce_key :persons, [Person]
    # 
    # This allows the objects inside of arrays to be parsed 
    module SuperCoercion
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def []=(key, value)
          if value && [Array,Hash].include?(value.class)
            into = self.class.key_coercion(key) || self.class.value_coercion(value)
            if value && into
              if into.class == Array && value.class == Array
                value = value.collect do |v| 
                  if into[0].respond_to?(:coerce)
                    into[0].coerce(v)
                  else
                    into[0].new(v)
                  end
                end
              elsif into.class == Hash && value.class == Hash
                into_value = into['key']
                value = value.inject({}) do |h, (k, v)| 
                  if into_value.respond_to?(:coerce)
                    h[k] = into_value.coerce(v)
                  else
                    h[k] = into_value.new(v)
                  end
                  h
                end
              else
                if into.respond_to?(:coerce)
                  value = into.coerce(value)
                else
                  value = into.new(value)
                end
              end
            end
          end

          super(key, value)
        end

        def custom_writer(key, value)
          self[key] = value
        end

        def replace(other_hash)
          (keys - other_hash.keys).each { |key| delete(key) }
          other_hash.each { |key, value| self[key] = value }
          self
        end
      end

      module ClassMethods
        # Set up a coercion rule such that any time the specified
        # key is set it will be coerced into the specified class.
        # Coercion will occur by first attempting to call Class.coerce
        # and then by calling Class.new with the value as an argument
        # in either case.
        #
        # @param [Object] key the key or array of keys you would like to be coerced.
        # @param [Class] into the class into which you want the key(s) coerced.
        #
        # @example Coerce a "user" subhash into a User object
        #   class Tweet < Hash
        #     include FamilySearch::Gedcomx::SuperCoercion
        #     coerce_key :user, User
        #     coerce_key :tags, [Tag]
        #   end
        def coerce_key(*attrs)
          @key_coercions ||= {}
          into = attrs.pop
          attrs.each { |key| @key_coercions[key] = into }
          if defined? @subclasses
            @subclasses.each { |klass| klass.coerce_key(attrs) }
          end
        end

        alias :coerce_keys :coerce_key

        # Returns a hash of any existing key coercions.
        def key_coercions
          @key_coercions || {}
        end

        # Returns the specific key coercion for the specified key,
        # if one exists.
        def key_coercion(key)
          key_coercions[key.to_sym]
        end
        
        def inherited(klass)
          super
          (@subclasses ||= Set.new) << klass
          klass.instance_variable_set('@key_coercions', self.key_coercions.dup)
          klass.instance_variable_set('@lenient_value_coercions', self.lenient_value_coercions.dup)
          klass.instance_variable_set('@strict_value_coercions', self.strict_value_coercions.dup)
        end

        # Set up a coercion rule such that any time a value of the
        # specified type is set it will be coerced into the specified
        # class.
        #
        # @param [Class] from the type you would like coerced.
        # @param [Class] into the class into which you would like the value coerced.
        # @option options [Boolean] :strict (true) whether use exact source class only or include ancestors
        #
        # @example Coerce all hashes into this special type of hash
        #   class SpecialHash < Hash
        #     include FamilySearch::Gedcomx::SuperCoercion
        #     coerce_value Hash, SpecialHash
        #
        #     def initialize(hash = {})
        #       super
        #       hash.each_pair do |k,v|
        #         self[k] = v
        #       end
        #     end
        #   end
        def coerce_value(from, into, options = {})
          options = {:strict => true}.merge(options)

          if options[:strict]
            (@strict_value_coercions ||= {})[from] = into
          else
            while from.superclass && from.superclass != Object
              (@lenient_value_coercions ||= {})[from] = into
              from = from.superclass
            end
          end
          if defined? @subclasses
            @subclasses.each { |klass| klass.coerce_value(from,into,options) }
          end
        end

        # Return all value coercions that have the :strict rule as true.
        def strict_value_coercions; @strict_value_coercions || {} end
        # Return all value coercions that have the :strict rule as false.
        def lenient_value_coercions; @value_coercions || {} end

        # Fetch the value coercion, if any, for the specified object.
        def value_coercion(value)
          from = value.class
          strict_value_coercions[from] || lenient_value_coercions[from]
        end
      end
    end
  end
end
