require "date"
require "time"

module Nomad
  class Response
    BUILTIN_LOADERS = {
      # Parses an integer as a timestamp (18394289434).
      date_as_timestamp: ->(item) { Time.at(item) },

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

      define_method(opts[:as] || n) do
        instance_variable_get(:"@#{ivar_for(n)}")
      end
    end

    # Returns the list of fields defined on this subclass.
    # @!visibility private
    def self.fields
      @fields ||= {}
    end

    # Decodes the given object (usually a Hash) into an instance of this class.
    #
    # @param object [Hash<Symbol, Object>]
    def self.decode(object)
      self.new(object)
    end

    def initialize(opts = {})
      # Initialize all fields as nil to start
      self.class.fields.each do |n, opts|
        instance_variable_set(:"@#{ivar_for(n)}", nil)
      end

      # For each supplied option, set the instance variable if it was defined
      # as a field.
      opts.each do |n, v|
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

          instance_variable_set(:"@#{ivar_for(n)}", v)
        end
      end
    end

    # Create a hash-bashed representation of this response.
    #
    # @return [Hash]
    def to_h
      self.class.fields.inject({}) do |h, (n, opts)|
        result = self.public_send(opts[:as] || n)

        if !result.nil? && !result.is_a?(Array) && result.respond_to?(:to_h)
          result = result.to_h
        end

        h[ivar_for(n)] = result
        h
      end
    end

    def ==(other)
      self.to_h == other.to_h
    end

    private

    def ivar_for(name)
      name = name.to_s
      name.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      name.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      name.tr!('-', '_')
      name.gsub!(/\s/, '_')
      name.gsub!(/__+/, '_')
      name.gsub!(/[^[:word:]+]/i, '_')
      name.downcase!
      return name.to_sym
    end
  end
end
