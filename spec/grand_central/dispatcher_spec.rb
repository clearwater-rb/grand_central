require 'grand_central/dispatcher'
require 'grand_central/store'
require 'grand_central/action'

module GrandCentral
  describe Dispatcher do
    let(:dispatch) { Dispatcher.for(store) }
    let(:store) {
      Store.new(0) do |state, action|
        case action
        when :increment then state + 1
        when :decrement then state - 1
        when action_class then action.value
        else state
        end
      end
    }
    let(:action_class) { Action.with_attributes(:value) }

    it 'forwards the action to the store' do
      dispatch.new(:increment).call
      expect(store.state).to eq 1

      dispatch.new(:decrement).call
      expect(store.state).to eq 0

      dispatch.new(:foo).call
      expect(store.state).to eq 0
    end

    it 'allows call to take arguments like DOM events' do
      dispatch.new { |event| action_class.new(event) }.call(123)
      expect(store.state).to eq 123
    end

    it 'cannot accept an action in both arguments and the block' do
      expect {
        dispatch.new(123) { 456 }
      }.to raise_error(ArgumentError)
    end
  end
end
