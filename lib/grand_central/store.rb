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
      run_callbacks old_state, state
      self
    end

    def on_dispatch &block
      @dispatch_callbacks << block
      self
    end

    def run_callbacks old_state, new_state
      @dispatch_callbacks.each do |callback|
        callback.call old_state, new_state
      end
    end
  end
end
