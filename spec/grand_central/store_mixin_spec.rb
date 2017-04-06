require 'grand_central/store'
require 'grand_central/store_mixin'

module GrandCentral
  RSpec.describe StoreMixin do
    # Store sets whatever is dispatched as the new state
    let(:store) { GrandCentral::Store.new(nil) { |state, action| action } }

    let(:mixin) { StoreMixin.for(store) }
    let(:component_class) do
      mixin = self.mixin
      Class.new do
        include mixin
      end
    end
    let(:component) { component_class.new }

    it 'adds state method to component' do
      store.dispatch 12
      expect(component.state).to eq 12
    end

    it 'adds dispatch method to component' do
      component.dispatch 45
      expect(component.state).to eq 45
    end

    it 'forwards on_dispatch handlers' do
      x = 0
      mixin.on_dispatch { x = 1 }

      component.dispatch :omg

      expect(x).to eq 1
    end
  end
end
