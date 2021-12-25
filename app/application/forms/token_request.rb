require 'dry-validation'

module NoFB
  module Forms
    class NewToken < Dry::Validation::Contract
      params do
        required(:code)
        required(:state)
      end
    end
  end
end
