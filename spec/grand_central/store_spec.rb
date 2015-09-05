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

    it 'passes old state and new state to dispatch callback' do
      store = Store.new([1]) do |state, action|
        state + [2]
      end
      store.on_dispatch do |old, new|
        expect(old).to eq [1]
        expect(new).to eq [1, 2]
      end

      store.dispatch :thing
    end
  end
end
