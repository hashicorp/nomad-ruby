require "spec_helper"

module Nomad
  describe Duration do
    {
      -1*Duration::MINUTE => {
        nanoseconds:  -60_000_000_000,
        microseconds: -60_000_000,
        milliseconds: -60_000,
        seconds:      -60,
        minutes:      -1,
        hours:        -0.016666666666666666,
        days:         -0.0006944444444444445,
        to_human:     "-1m",
      },

      0 => {
        nanoseconds:  0,
        microseconds: 0,
        milliseconds: 0,
        seconds:      0,
        minutes:      0,
        hours:        0,
        days:         0,
        to_human:     "0ns",
      },

      1 => {
        nanoseconds:  1,
        microseconds: 0.001,
        milliseconds: 0.000001,
        seconds:      0.000000001,
        minutes:      0.000000000016666666666666666,
        hours:        0.0000000000002777777777777778,
        days:         0.000000000000011574074074074074,
        to_human:     "1ns",
      },

      1_000 => {
        nanoseconds:  1_000,
        microseconds: 1,
        milliseconds: 0.001,
        seconds:      0.000001,
        minutes:      0.000000016666666666666666,
        hours:        0.00000000027777777777777776,
        days:         0.000000000011574074074074074,
        to_human:     "1us",
      },

      1_000_000 => {
        nanoseconds:  1_000_000,
        microseconds: 1_000,
        milliseconds: 1,
        seconds:      0.001,
        minutes:      0.000016666666666666666,
        hours:        0.00000027777777777777776,
        days:         0.000000011574074074074074,
        to_human:     "1ms",
      },

      1_000_000_000 => {
        nanoseconds:  1_000_000_000,
        microseconds: 1_000_000,
        milliseconds: 1_000,
        seconds:      1,
        minutes:      0.016666666666666666,
        hours:        0.0002777777777777778,
        days:         0.000011574074074074073,
        to_human:     "1s",
      },

      60*Duration::SECOND => {
        nanoseconds:  60_000_000_000,
        microseconds: 60_000_000,
        milliseconds: 60_000,
        seconds:      60,
        minutes:      1,
        hours:        0.016666666666666666,
        days:         0.0006944444444444445,
        to_human:     "1m",
      },

      60*Duration::MINUTE => {
        nanoseconds:  3_600_000_000_000,
        microseconds: 3_600_000_000,
        milliseconds: 3_600_000,
        seconds:      3_600,
        minutes:      60,
        hours:        1,
        days:         0.041666666666666664,
        to_human:     "1h",
      },

      24*Duration::HOUR => {
        nanoseconds:  86_400_000_000_000,
        microseconds: 86_400_000_000,
        milliseconds: 86_400_000,
        seconds:      86_400,
        minutes:      1_440,
        hours:        24,
        days:         1,
        to_human:     "1d",
      },

      3*Duration::DAY + 7*Duration::HOUR + 22*Duration::MINUTE + 23*Duration::SECOND + 224*Duration::MILLI_SECOND => {
        nanoseconds:  285_743_224_000_000,
        microseconds: 285_743_224_000,
        milliseconds: 285_743_224,
        seconds:      285_743.224,
        minutes:      4_762.387066666666,
        hours:        79.37311777777778,
        days:         3.3072132407407406,
        to_human:     "3d7h22m23s224ms",
      },
    }.each do |i, list|
      list.sort.each do |k,v|
        describe "##{k}(#{i})" do
          it "returns #{v}" do
            instance = Duration.new(i)
            result = instance.public_send(k)
            expect(result).to eq(v)
          end
        end
      end
    end

    describe "#to_human" do
      {
        d:  "1d",
        h:  "1d2h",
        m:  "1d2h3m",
        s:  "1d2h3m4s",
        ms: "1d2h3m4s5ms",
        us: "1d2h3m4s5ms6us",
        ns: "1d2h3m4s5ms6us7ns",
      }.each do |label, exp|
        it "rounds to the nearest #{label}" do
          instance = Duration.new(
            1*Duration::DAY +
            2*Duration::HOUR +
            3*Duration::MINUTE +
            4*Duration::SECOND +
            5*Duration::MILLI_SECOND +
            6*Duration::MICRO_SECOND +
            7*Duration::NANO_SECOND +
            0
          )
          result = instance.to_human(label)
          expect(result).to eq(exp)
        end
      end
    end

    describe "numeric" do
      it "behaves like a numeric" do
        instance = Duration.new(100*Duration::NANO_SECOND)
        instance = instance + 100
        expect(instance).to eq(Duration.new(200*Duration::NANO_SECOND))
      end
    end
  end
end
