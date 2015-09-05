module GrandCentral
  class Store
    attr_reader :state

    def initialize initial_state, &reducer
      @state = initial_state
      @reducer = reducer
      @dispatch_callbacks = []
    end

    def dispatch action
      old_state = state
      @state = @reducer.call state, action
      @dispatch_callbacks.each do |callback|
        callback.call old_state, state
      end
      self
    end

    def on_dispatch &block
      @dispatch_callbacks << block
      self
    end
  end
end
