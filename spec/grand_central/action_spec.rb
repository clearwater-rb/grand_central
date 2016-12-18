require 'grand_central/action'
require 'support/namespace'

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

    describe 'serialization' do
      let(:blank) do
        Action.create do
          def self.name
            'BlankAction'
          end
        end
      end
      let(:has_attributes) do
        Action.with_attributes(:foo, :bar) do
          def self.name
            'HasAttributes'
          end
        end
      end

      it 'serializes to JSON' do
        expect(blank.new.to_serializable_format).to eq(
          '$class' => 'BlankAction'
        )

        expect(has_attributes.new(1, 'two').to_serializable_format).to eq(
          '$class' => 'HasAttributes',
          'foo' => 1,
          'bar' => 'two',
        )
      end

      it 'deserializes from JSON' do
        namespace = Namespace.new(
          'BlankAction' => blank,
          'HasAttributes' => has_attributes,
        )

        blank_action = Action.deserialize(
          { '$class' => 'BlankAction' },
          namespace: namespace,
        )

        has_attributes_action = Action.deserialize(
          {
            '$class' => 'HasAttributes',
            'foo' => 1,
            'bar' => 'two',
          },
          namespace: namespace
        )

        expect(blank_action).to be_a blank
        expect(has_attributes_action).to be_a has_attributes
        expect(has_attributes_action.foo).to eq 1
        expect(has_attributes_action.bar).to eq 'two'
      end
    end
  end
end
