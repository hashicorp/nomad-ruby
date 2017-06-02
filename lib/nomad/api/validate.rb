require_relative "../client"
require_relative "../request"

module Nomad
  class Client
    # A proxy to the {Validate} methods.
    # @return [Validate]
    def validate
      @validate ||= Validate.new(self)
    end
  end

  class Validate < Request
    # Validate a JSON job.
    #
    # @example
    #   Nomad.validate.job #=> #<JobValidation ...>
    #
    # @return [JobValidation]
    def job(payload, **options)
      json = client.post("/v1/validate/job", payload, options)
      return JobValidation.decode(json)
    end
  end

  class JobValidation < Response
    # @!attribute [r] driver_config_validated
    #   The evaluation driver_config_validated.
    #   @return [Boolean]
    field :DriverConfigValidated, as: :driver_config_validated

    # @!attribute [r] validation_errors
    #   The evaluation validation_errors.
    #   @return [Array<String>]
    field :ValidationErrors, as: :validation_errors, load: :nil_as_array

    # @!attribute [r] error
    #   The evaluation error.
    #   @return [String]
    field :Error, as: :error, load: :string_as_nil

    # Determines if the validation errored.
    # @return [Boolean]
    def errored?
      return !self.error.nil? || !self.validation_errors.empty?
    end
  end
end
