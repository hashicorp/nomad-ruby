require "forwardable"

module Nomad
  # Convention of upper vs lower
  class Size
    BIT       = Float(1)
    BYTE      = 8 * BIT
    KILOBIT   = 1_000 * BIT
    KILOBYTE  = 1_000 * BYTE
    MEGABIT   = 1_000 * KILOBIT
    MEGABYTE  = 1_000 * KILOBYTE
    GIGABIT   = 1_000 * MEGABIT
    GIGABYTE  = 1_000 * MEGABYTE
    TERABIT   = 1_000 * GIGABIT
    TERABYTE  = 1_000 * GIGABYTE
    PETABIT   = 1_000 * TERABIT
    PETABYTE  = 1_000 * TERABYTE
    EXABIT    = 1_000 * PETABIT
    EXABYTE   = 1_000 * PETABYTE
    ZETTABIT  = 1_000 * EXABIT
    ZETTABYTE = 1_000 * EXABYTE
    YOTTABIT  = 1_000 * ZETTABIT
    YOTTABYTE = 1_000 * ZETTABYTE

    LABEL_BIT       = "b".freeze
    LABEL_BYTE      = "B".freeze
    LABEL_KILOBIT   = "kb".freeze
    LABEL_KILOBYTE  = "kB".freeze
    LABEL_MEGABIT   = "Mb".freeze
    LABEL_MEGABYTE  = "MB".freeze
    LABEL_GIGABIT   = "Gb".freeze
    LABEL_GIGABYTE  = "GB".freeze
    LABEL_TERABIT   = "Tb".freeze
    LABEL_TERABYTE  = "TB".freeze
    LABEL_PETABIT   = "Pb".freeze
    LABEL_PETABYTE  = "PB".freeze
    LABEL_EXABIT    = "Eb".freeze
    LABEL_EXABYTE   = "EB".freeze
    LABEL_ZETTABIT  = "Zb".freeze
    LABEL_ZETTABYTE = "ZB".freeze
    LABEL_YOTTABIT  = "Yb".freeze
    LABEL_YOTTABYTE = "YB".freeze

    LABELS_MAP = {
      LABEL_YOTTABYTE => YOTTABYTE,
      LABEL_YOTTABIT  => YOTTABIT,
      LABEL_ZETTABYTE => ZETTABYTE,
      LABEL_ZETTABIT  => ZETTABIT,
      LABEL_EXABYTE   => EXABYTE,
      LABEL_EXABIT    => EXABIT,
      LABEL_PETABYTE  => PETABYTE,
      LABEL_PETABIT   => PETABIT,
      LABEL_TERABYTE  => TERABYTE,
      LABEL_TERABIT   => TERABIT,
      LABEL_GIGABYTE  => GIGABYTE,
      LABEL_GIGABIT   => GIGABIT,
      LABEL_MEGABYTE  => MEGABYTE,
      LABEL_MEGABIT   => MEGABIT,
      LABEL_KILOBYTE  => KILOBYTE,
      LABEL_KILOBIT   => KILOBIT,
      LABEL_BYTE      => BYTE,
      LABEL_BIT       => BIT,
    }.freeze

    # Delegate all standard math operations to the number of bits.
    extend Forwardable
    def_delegators :@b, *(Integer.instance_methods(false) - [:to_s, :inspect])

    # Initialize accepts the numer of bits as an Integer or Float and
    # builds the conversions around it.
    #
    # @example
    #   Size.new(1342902)
    #
    # @example More human friendly
    #   Size.new(3*Size::KILOBYTES) # 3 KB
    def initialize(b)
      @b = Float(b || 0)
    end

    def bits
      @b / BIT
    end

    def bytes
      @b / BYTE
    end

    def kilobits
      @b / KILOBIT
    end

    def kilobytes
      @b / KILOBYTE
    end

    def megabits
      @b / MEGABIT
    end

    def megabytes
      @b / MEGABYTE
    end

    def gigabits
      @b / GIGABIT
    end

    def gigabytes
      @b / GIGABYTE
    end

    def terabits
      @b / TERABIT
    end

    def terabytes
      @b / TERABYTE
    end

    def petabits
      @b / PETABIT
    end

    def petabytes
      @b / PETABYTE
    end

    def exabits
      @b / EXABIT
    end

    def exabytes
      @b / EXABYTE
    end

    def zettabits
      @b / ZETTABIT
    end

    def zettabytes
      @b / ZETTABYTE
    end

    def yottabits
      @b / YOTTABIT
    end

    def yottabytes
      @b / YOTTABYTE
    end

    # The "human-friendly" form of this duration. Large values are rounded off,
    # sacrificing correctness for readability. The underlying data is still
    # correct and the real value can be retrieved by calling another method.
    #
    # @example
    #   size.to_s #=> "5GB"
    #
    # @return [String]
    def to_s
      b, negative = @b, false
      if b < 0
        b *= -1
        negative = true
      end

      biggest = LABELS_MAP.find { |l,c| b / c >= 1 }

      if biggest.nil?
        return String(b.round(0)) << LABEL_BIT
      end

      result = String((b / biggest[1]).round(0)) << biggest[0]

      return "-" << result if negative
      return result
    end

    def inspect
      "#<%s:0x%s %s>" % [self.class, (object_id << 1).to_s(16), "@size=\"#{to_s}\""]
    end
  end
end
