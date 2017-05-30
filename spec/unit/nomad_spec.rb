require "spec_helper"

describe Nomad do
  it "sets the default values" do
    Nomad::Configurable.keys.each do |key|
      value = Nomad::Defaults.send(key)
      expect(Nomad.client.instance_variable_get(:"@#{key}")).to eq(value)
    end
  end

  describe ".client" do
    it "returns the Nomad::Client" do
      expect(Nomad.client).to be_a(Nomad::Client)
    end
  end

  describe ".configure" do
    Nomad::Configurable.keys.each do |key|
      it "sets the client's #{key.to_s.gsub("_", " ")}" do
        Nomad.configure do |config|
          config.send("#{key}=", key)
        end

        expect(Nomad.client.instance_variable_get(:"@#{key}")).to eq(key)
      end
    end
  end

  describe ".method_missing" do
    context "when the client responds to the method" do
      let(:client) { double(:client) }
      before { Nomad.instance_variable_set(:@client, client) }

      it "delegates the method to the client" do
        allow(client).to receive(:bacon).and_return("awesome")
        expect { Nomad.bacon }.to_not raise_error
      end
    end

    context "when the client does not respond to the method" do
      it "calls super" do
        expect { Nomad.bacon }.to raise_error(NoMethodError)
      end
    end
  end

  describe ".respond_to_missing?" do
    let(:client) { double(:client) }
    before { allow(Nomad).to receive(:client).and_return(client) }

    it "delegates to the client" do
      expect { Nomad.respond_to_missing?(:foo) }.to_not raise_error
    end
  end
end
