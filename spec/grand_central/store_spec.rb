require 'grand_central/store'

module GrandCentral
  describe Store do
    it 'sets up initial state' do
      store = Store.new(:foo) {}

      expect(store.state).to eq :foo
    end

    it 'can have actions dispatched' do
      my_action = nil
      store = Store.new(:foo) do |state, action|
        my_action = action
      end
      store.dispatch :my_action

      expect(my_action).to eq :my_action
    end

    it 'uses the return value of the reducer function as new state' do
      store = Store.new([1]) do |state, action|
        state + [2]
      end

      store.dispatch 'lol whatever'

      expect(store.state).to eq [1, 2]
    end

    it 'runs on_dispatch hooks after dispatching' do
      store = Store.new([1]) do |state, action|
        state + [2]
      end
      runs = 0
      store.on_dispatch do
        runs += 1
      end

      store.dispatch :first
      store.dispatch :second

      expect(runs).to eq 2
    end

    it 'passes old state, new state, and action to dispatch callback' do
      store = Store.new([1]) do |state, action|
        state + [2]
      end
      store.on_dispatch do |old, new, action|
        expect(old).to eq [1]
        expect(new).to eq [1, 2]
        expect(action).to eq :thing
      end

      store.dispatch :thing
    end

    it 'returns the action after the dispatch' do
      store = Store.new(1) {}
      expect(store.dispatch(:thing)).to eq :thing
    end

    it 'can have its handler changed' do
      store = Store.new(1) { |state| state + 1 }
      store.dispatch :omg

      expect(store.state).to eq 2

      store.handler = proc { |state| state - 1 }
      store.dispatch :omg

      expect(store.state).to eq 1
    end
  end
end
