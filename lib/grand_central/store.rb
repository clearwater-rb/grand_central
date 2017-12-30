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
      run_callbacks old_state, state, action
      action
    end

    def on_dispatch &block
      @dispatch_callbacks << block
      self
    end

    def run_callbacks old_state, new_state, action=nil
      @dispatch_callbacks.each do |callback|
        callback.call old_state, new_state, action
      end
    end

    attr_writer :reducer
    alias handler= reducer=
  end
end
