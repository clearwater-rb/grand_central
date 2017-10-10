require 'grand_central/action'
require 'grand_central/store'

module GrandCentral
  describe Action do
    it 'generates new action subclasses with specified attributes' do
      my_class = Action.with_attributes(:foo)
      action = my_class.new(:bar)

      expect(action).to be_a Action
      expect(action.foo).to eq :bar
    end

    it 'generates a new action subclass with no attributes' do
      my_class = Action.create
      action = my_class.new

      expect(action).to be_a Action
    end

    it 'takes a class body' do
      action_class = Action.with_attributes(:foo) do
        def baz
          foo.to_s
        end
      end
      action = action_class.new(:bar)

      expect(action.baz).to eq 'bar'
    end

    it "delegates promise methods to the action's promise" do
      then_called = false
      fail_called = false
      always_called = false

      action = Action.create.new
      promise = Object.new
      def promise.then &block
        block.call
        self
      end
      def promise.fail &block
        block.call
        self
      end
      def promise.always &block
        block.call
        self
      end

      action.define_singleton_method :promise do
        promise
      end

      action
        .then   { then_called   = true }
        .fail   { fail_called   = true }
        .always { always_called = true }

      expect(then_called).to be_truthy
      expect(fail_called).to be_truthy
      expect(always_called).to be_truthy
    end

    it 'can dispatch to a store' do
      action_class = Action.with_attributes(:foo, :bar)
      store = Store.new(false) do |state, action|
        case action
        when action_class
          [action.foo, action.bar]
        else
          raise "Action is not the expected action class"
        end
      end
      action_class.store = store

      expect(action_class)
        .to receive(:new)
        .with(1, 2)
        .and_call_original

      expect(store)
        .to receive(:dispatch)
        .and_call_original

      action = action_class[1].call(2)

      expect(action).to be_a action_class
      expect(action.foo).to eq 1
      expect(action.bar).to eq 2
      expect(store.state).to eq [1, 2]
    end

    it 'can be executed as a block' do
      klass = Action.with_attributes(:foo, :bar)
      store = Store.new(nil) do |state, action|
        case action
        when klass
          [action.foo, action.bar]
        else
          raise "Action is not the expected action"
        end
      end
      klass.store = store

      # klass.call 1, 2

      [[1, 2]].each(&klass)

      expect(store.state).to eq [1, 2]
    end

    it 'can have delayed execution as a block' do
      klass = Action.with_attributes(:foo, :bar)
      store = Store.new(nil) do |state, action|
        case action
        when klass
          [action.foo, action.bar]
        else
          raise "Unexpected action"
        end
      end
      klass.store = store

      [[]].each(&klass[1, 2])

      expect(store.state).to eq [1, 2]
    end

    it 'can curry indefinitely' do
      klass = Action.with_attributes(:a, :b, :c)
      store = Store.new(0) { |state, action| [action.a, action.b, action.c] }
      klass.store = store

      action = klass[1][2][3].call

      expect(store.state).to eq [1, 2, 3]
    end
  end
end
