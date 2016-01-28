require 'grand_central/action'

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
  end
end
