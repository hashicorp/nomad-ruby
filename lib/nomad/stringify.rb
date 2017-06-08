module Nomad
  module Stringify

    # Converts all keys in a map to string (instead of symbol) keys.
    #
    # @param [Hash] hash
    #
    # @return [Hash]
    def stringify_keys(hash)
      (hash || {}).inject({}) do |h, (key, value)|
        value = value.map { |h| stringify_keys(h) } if value.is_a?(Array)
        value = stringify_keys(value) if value.is_a?(Hash)
        h[key.to_s] = value
        h
      end
    end

    module_function :stringify_keys
  end
end
