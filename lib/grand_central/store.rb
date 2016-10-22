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

    def state_mixin
      return @state_mixin if defined? @state_mixin

      m = method(:state)
      @state_mixin = Module.new { define_method(:state, &m) }
    end

    def dispatcher
      return @dispatcher if defined? @dispatcher

      m = method(:dispatch)
      @dispatcher = Module.new { define_method(:dispatch, &m) }
    end

    def mixin
      return @mixin if defined? @mixin

      state = state_mixin
      dispatcher = self.dispatcher
      @mixin = Module.new do
        include state
        include dispatcher
      end
    end
  end
end
