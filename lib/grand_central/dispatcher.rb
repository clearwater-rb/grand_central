module GrandCentral
  module Dispatcher
    def self.for store
      Class.new do
        define_method :initialize do |*args, &block|
          if args.any? && block
            fail ArgumentError,
              "Cannot provide an action in both arguments and a block"
          end

          @store = store
          @action = args.first || block
        end

        def call *args
          action = if Proc === @action
                     @action.call(*args)
                   else
                     @action
                   end

          @store.dispatch action
        end
      end
    end
  end
end
