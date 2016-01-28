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
  end
end
