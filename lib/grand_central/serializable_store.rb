require 'grand_central/store'
require 'grand_central/model'
require 'grand_central/action'

module GrandCentral
  class SerializableStore < Store
    attr_reader :actions

    def initialize initial_state
      super

      @initial_state = initial_state
      @actions = []
    end

    def dispatch action
      result = super

      @actions << action
      result
    end

    def load serialized, namespace: Object
      initial_state = serialized.fetch(:initial_state) { serialized['initial_state'] }
      actions = serialized.fetch(:actions) { serialized['actions'] }

      @initial_state = Model.deserialize(initial_state, namespace: namespace)
      @actions = actions.map do |action|
        Action.deserialize(action, namespace: namespace)
      end

      @state = @actions.reduce(@initial_state, &@reducer)
    end

    def to_serializable_format
      {
        'initial_state' => @initial_state.to_serializable_format,
        'actions' => @actions.map(&:to_serializable_format),
      }
    end
  end
end
