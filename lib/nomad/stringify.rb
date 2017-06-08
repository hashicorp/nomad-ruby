module Nomad
  module Stringify

    # Converts all keys in a map to string (instead of symbol) keys.
    #
    # @param [Hash] hash
    #
    # @return [Hash]
    def stringify_keys(hash)
      (hash || {}).inject({}) do |h, (key, value)|
        if value.is_a?(Array)
          value = value.map do |i|
            if i.is_a?(Hash) || i.is_a?(Array)
              stringify_keys(i)
            else
              i
            end
          end
        end

        if value.is_a?(Hash)
          value = stringify_keys(value)
        end

        h[key.to_s] = value
        h
      end
    end

    module_function :stringify_keys
  end
end
