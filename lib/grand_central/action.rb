module GrandCentral
  class Action
    def self.with_attributes *attributes, &body
      klass = Class.new(self)
      klass.send :define_method, :initialize do |*args|
        attributes.each_with_index do |attribute, index|
          instance_variable_set "@#{attribute}", args[index]
        end
      end
      klass.send :attr_reader, *attributes
      klass.class_exec &body if block_given?

      klass
    end

    def self.create &block
      with_attributes &block
    end

    def then &block
      promise.then &block
    end

    def fail &block
      promise.fail &block
    end

    def always &block
      promise.always &block
    end

    class << self
      attr_writer :store
    end

    def self.store
      if self == Action
        @store
      else
        @store || superclass.store
      end
    end

    def self.call(*args)
      Dispatcher.new(self, store, []).call(*args)
    end

    def self.[](*args)
      Dispatcher.new(self, store, args)
    end

    class Dispatcher
      def initialize action_class, store, args
        @action_class = action_class
        @store = store
        @args = args

        if store.nil?
          raise ArgumentError, "No store set for #{action_class}"
        end
      end

      def call *args
        if args.first.class.name == 'Bowser::Event'
          event = args.first
          case event.type
          when 'submit'
            event.prevent
          when 'input'
            args = event.target.value
          end
        end
        @store.dispatch @action_class.new(*@args, *args)
      end
    end
  end
end
