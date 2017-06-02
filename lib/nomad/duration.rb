require "forwardable"

module Nomad
  # Duration is a time extension to match Golang's number types. The raw
  # underlying value is a float representing the number of nanoseconds. This
  # class provides convenience functions for converting those durations into
  # more meaningful numbers.
  #
  # Note that the return type is always a _float_, even for time operations that
  # convert evenly.
  #
  # @example Create a time duration
  #   time = 50*Duration::SECOND # 50 seconds
  #   time = 1*Duration::MINUTE + 50*Duration::SECOND # 1 minute, 50 seconds
  #
  # @example Convert a time to another format
  #   time = 60*Duration::SECOND
  #   time.minutes #=> 1.0
  #
  # @example Human print the time
  #   60*Duration::Second.to_s #=> "60s"
  #   Duration.new(248902890389024).to_human #=> "2d21h8m22s890ms389us24ns"
  #
  # @example Human print the time up to seconds, ignoring anything less that seconds
  #   Duration.new(248902890389024).to_human(:s) #=> "2d21h8m22s"
  class Duration
    NANO_SECOND  = Float(1)
    MICRO_SECOND = 1_000 * NANO_SECOND
    MILLI_SECOND = 1_000 * MICRO_SECOND
    SECOND       = 1_000 * MILLI_SECOND
    MINUTE       = 60 * SECOND
    HOUR         = 60 * MINUTE
    DAY          = 24 * HOUR

    LABEL_NANO_SECOND  = "ns".freeze
    LABEL_MICRO_SECOND = "us".freeze
    LABEL_MILLI_SECOND = "ms".freeze
    LABEL_SECOND       = "s".freeze
    LABEL_MINUTE       = "m".freeze
    LABEL_HOUR         = "h".freeze
    LABEL_DAY          = "d".freeze

    LABELS_MAP = {
      LABEL_DAY          => DAY,
      LABEL_HOUR         => HOUR,
      LABEL_MINUTE       => MINUTE,
      LABEL_SECOND       => SECOND,
      LABEL_MILLI_SECOND => MILLI_SECOND,
      LABEL_MICRO_SECOND => MICRO_SECOND,
      LABEL_NANO_SECOND  => NANO_SECOND,
    }.freeze

    # Delegate all standard math operations to the number of nanoseconds.
    extend Forwardable
    def_delegators :@ns, *(Integer.instance_methods(false) - [:to_s, :inspect])

    # Initialize accepts the numer of nanoseconds as an Integer or Float and
    # builds the duration parsing around it.
    #
    # @example
    #   Duration.new(1342902)
    #
    # @example More human friendly
    #   Duration.new(3*Duration::HOUR) # 3 hours
    def initialize(ns)
      @ns = Float(ns)
    end

    # The complete number of nanoseconds. This will always be a whole number,
    # but the return type is a float for easier chaining and consistency.
    #
    # @example
    #   duration.nanoseconds #=> 32389042.0
    #
    # @return [Float]
    def nanoseconds
      @ns / NANO_SECOND
    end

    # The complete number of microseconds. Non-whole-microseconds parts are
    # represented as decimals.
    #
    # @example
    #   duration.microseconds #=> 42904289.248
    #
    # @return [Float]
    def microseconds
      @ns / MICRO_SECOND
    end

    # The complete number of milliseconds. Non-whole-milliseconds parts are
    # represented as decimals.
    #
    # @example
    #   duration.milliseconds #=> 42904289.248
    #
    # @return [Float]
    def milliseconds
      @ns / MILLI_SECOND
    end

    # The complete number of seconds. Non-whole-seconds parts are represented as
    # decimals.
    #
    # @example
    #   duration.seconds #=> 42904289.248
    #
    # @return [Float]
    def seconds
      @ns / SECOND
    end

    # The complete number of minutes. Non-whole-minutes parts are represented as
    # decimals.
    #
    # @example
    #   duration.minutes #=> 42904289.248
    #
    # @return [Float]
    def minutes
      @ns / MINUTE
    end

    # The complete number of hours. Non-whole-hours parts are represented as
    # decimals.
    #
    # @example
    #   duration.hours #=> 42904289.248
    #
    # @return [Float]
    def hours
      @ns / HOUR
    end

    # The complete number of days. Non-whole-days parts are represented as
    # decimals.
    #
    # @example
    #   duration.days #=> 42904289.248
    #
    # @return [Float]
    def days
      @ns / DAY
    end

    # The "human-friendly" form of this duration. By default, the time is
    # displayed up to the total number of nanoseconds, with each part maximized
    # before continuing to the smallest part (i.e. 24h becomes 1d). Fields with
    # zero value are omitted.
    #
    # An optional "highest label" may be supplied to limit the output to a
    # particular label.
    #
    # NOTE: this method does its best to be performant, but it's inherently not
    # by the requirement to re-calculate on each invocation. If you are calling
    # this multiple times, consider caching the value in your code.
    #
    # @example
    #   duration.to_human #=> "2d9h32m44s944ms429us193ns"
    #
    # @example Limit to hours
    #   duration.to_human(:h) #=> "2d9h"
    #
    # @return [String]
    def to_human(highest = LABEL_NANO_SECOND)
      highest = highest.to_s if !highest.is_a?(String)
      if !LABELS_MAP.key?(highest)
        raise "Invalid label `#{highest}'!"
      end

      t, str, negative = @ns, "", false
      if t < 0
        t *= -1
        negative = true
      end

      LABELS_MAP.each do |l,c|
        if (item = (t / c).floor(0)) > 0
          str << String(item) << l
          t -= (item * c)
        end
        break if l == highest
      end

      return "0" << highest if str.empty?
      return "-" << str if negative
      return str
    end
  end
end
