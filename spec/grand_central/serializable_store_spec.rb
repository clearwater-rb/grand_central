require 'grand_central/serializable_store'
require 'grand_central/model'
require 'grand_central/action'
require 'support/namespace'

module GrandCentral
  RSpec.describe SerializableStore do
    let(:store) do
      SerializableStore.new(initial_state) do |state, action|
        case action
        when foo
          state.update foo: true
        when bar
          state.update bar: action.bar
        when baz
          state.update baz: action.baz
        else
          state
        end
      end
    end

    let(:initial_state) { state.new(foo: false, bar: 0, baz: nil) }
    let(:foo) { action.create { name 'Foo' }}
    let(:bar) { action.with_attributes(:bar) { name 'Bar' } }
    let(:baz) { action.with_attributes(:baz) { name 'Baz' } }
    # Make it easy to define class names for these anonymous action classes
    let(:action) do
      Action.create do
        def self.name(*args)
          if args.any?
            @name = args.first
          else
            @name
          end
        end
      end
    end
    let(:state) do
      Class.new(Model) do
        attributes(:foo, :bar, :baz)

        def self.name
          'AppState'
        end
      end
    end
    let(:serialized) do
      {
        'initial_state' => {
          '$class' => 'AppState',
          'foo' => false,
          'bar' => 0,
          'baz' => nil,
        },
        'actions' => [
          { '$class' => 'Foo' },
          { '$class' => 'Bar', 'bar' => 12 },
          { '$class' => 'Baz', 'baz' => 'omg' },
        ],
      }
    end

    let(:namespace) do
      Namespace.new(
        'Foo' => foo,
        'Bar' => bar,
        'Baz' => baz,
        'AppState' => state,
      )
    end

    it 'serializes state and actions' do
      store.dispatch foo.new
      store.dispatch bar.new(12)
      store.dispatch baz.new('omg')

      expect(store.to_serializable_format).to eq(serialized)
    end

    it 'replays serialized format' do
      store.load(serialized, namespace: namespace)

      state = store.state
      expect(state.foo).to eq true
      expect(state.bar).to eq 12
      expect(state.baz).to eq 'omg'
    end
  end
end
