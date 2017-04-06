require 'grand_central/store'

module GrandCentral
  RSpec.describe 'Store mixin' do
    # Store sets whatever is dispatched as the new state
    let(:store) { GrandCentral::Store.new(nil) { |state, action| action } }
    let(:component_class) { Class.new }
    let(:component) { component_class.new }

    it 'adds state method to component' do
      component_class.include store.state_mixin

      store.dispatch 12

      expect(component.state).to eq 12
    end

    it 'adds dispatch method to component' do
      component_class.include store.dispatcher

      component.dispatch 45

      expect(store.state).to eq 45
    end

    it 'adds both state and dispatch in a single mixin' do
      component_class.include store.mixin

      component.dispatch 42

      expect(component.state).to eq 42
    end

    # These check efficiency. We don't want to generate a new mixin for 1000
    # different classes that include it if they can all safely use the same one.
    describe 'mixin reuse' do
      it 'reuses the state mixin' do
        expect(store.state_mixin).to be store.state_mixin
      end

      it 'reuses the dispatcher mixin' do
        expect(store.dispatcher).to be store.dispatcher
      end

      it 'reuses the all-purpose mixin' do
        expect(store.dispatcher).to be store.dispatcher
      end
    end
  end
end
