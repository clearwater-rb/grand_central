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
      self[*args].call
    end

    def self.[](*args)
      DelayedDispatch.new(self, store, args)
    end

    def self.to_proc
      proc { |*args| call *args.flatten(1) }
    end

    # A DelayedDispatch is an object that represents a dispatch that is intended
    # to happen later. Arguments can be provided upfront, which will be used as
    # the first args to the action constructor when the dispatch occurs.
    #
    # When you `call` the DelayedDispatch, the arguments given to `call` are
    # used as the remaining arguments to the action constructor. The action is
    # created and dispatched to the specified store.
    #
    # If you're familiar with functional programming, this is really just a
    # curried `Action.call`, where the currying only happens once.
    class DelayedDispatch
      def initialize action_class, store, args
        @action_class = action_class
        @store = store
        @args = args

        if store.nil?
          raise ArgumentError, "No store set for #{action_class}"
        end
      end

      def call *args
        @store.dispatch @action_class.new(*handle_bowser_event(@args + args))
      end

      def to_proc
        proc { |*args| call *args.flatten(1) }
      end

      # Add support for Bowser::Event args. This is so that front-end apps can
      # handle DOM events in a much more convenient way.
      def handle_bowser_event args
        unless RUBY_ENGINE == 'opal'
          return args
        end

        args.map do |arg|
          if arg.class.name == 'Bowser::Event'
            event = arg

            case event.type
            when 'submit'
              # We're modifying a value we received, which is usually a no-no, but
              # in this case it's the most pragmatic solution I can think of.
              event.prevent
              event
            when 'input'
              event.target.value
            when 'change'
              element = event.target

              # In hindsight, using Element#type for the tag type was a bad idea.
              # It means we need to dip into JS to get the damn type property.
              if element.type == 'input' && `#{element.to_n}.type` == 'checkbox'
                element.checked?
              else
                element.value
              end
            else
              arg
            end
          else
            arg
          end
        end
      end
    end
  end
end
