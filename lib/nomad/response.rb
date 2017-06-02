require "date"
require "time"

require_relative "stringify"

module Nomad
  class Response
    BUILTIN_LOADERS = {
      # Loads an array as an array of strings
      array_of_strings: ->(item) { Array(item).map(&:to_s) },

      # Parses an integer as a timestamp (18394289434).
      date_as_timestamp: ->(item) { Time.at(item || 0) },

      # Parses the given integer as a duration.
      int_as_duration: ->(item) { Duration.new(item || 0) },

      # Parses the given integer as a "size".
      int_as_size_in_megabytes: ->(item) { Size.new(Float(item || 0) * Size::MEGABYTE) },

      # Parses the given integer as a "size".
      int_as_size_in_megabits: ->(item) { Size.new(Float(item || 0) * Size::MEGABIT) },

      # Returns an empty array if the given item is nil, otherwise returns the
      # item.
      nil_as_array: ->(item) { item || [] },

      # Parses the value as a string, converting "" to nil (go compat).
      string_as_nil: ->(item) {
        if item.nil? || item.strip.empty?
          nil
        else
          item
        end
      },

      stringify_keys: ->(item) { Stringify.stringify_keys(item) },
    }.freeze

    # Defines a new field. This is designed to be used by the subclass as a
    # mini-DSL.
    #
    # @example Default
    #   field :data
    #
    # @example With a mutator
    #   field :present, as: :present?
    #
    # @param n [Symbol] the name of the field
    # @option opts [Symbol] :as alias for method name
    # @option opts [Symbol] :load custom loader/parser for data
    #
    # @!visibility private
    def self.field(n, opts = {})
      self.fields[n] = opts

      opts[:as] = (opts[:as] || n).to_sym
      attr_reader opts[:as]
    end

    # Returns the list of fields defined on this subclass.
    # @!visibility private
    def self.fields
      @fields ||= {}
    end

    # Decodes the given object (usually a Hash) into an instance of this class.
    #
    # @param object [Hash<Symbol, Object>]
    # @return [Object, nil]
    def self.decode(object)
      return nil if object.nil?
      self.new(object)
    end

    def initialize(input = {})
      # Initialize all fields as nil to start
      self.class.fields.each do |n, opts|
        instance_variable_set(:"@#{opts[:as]}", nil)
      end

      # For each supplied option, set the instance variable if it was defined
      # as a field.
      input.each do |n, v|
        if self.class.fields.key?(n)
          opts = self.class.fields[n]

          if (m = opts[:load])
            if m.is_a?(Symbol)
              v = BUILTIN_LOADERS[m].call(v)
            else
              v = m.call(v)
            end
          end

          if opts[:freeze]
            v = v.freeze
          end

          instance_variable_set(:"@#{opts[:as]}", v)
        end
      end
    end

    # Create a hash-bashed representation of this response.
    #
    # @return [Hash]
    def to_h
      self.class.fields.inject({}) do |h, (n, opts)|
        result = self.public_send(opts[:as])

        if !result.nil? && !result.is_a?(Array) && result.respond_to?(:to_h)
          result = result.to_h
        end

        h[opts[:as]] = result
        h
      end
    end

    def ==(other)
      self.to_h == other.to_h
    end
  end
end
