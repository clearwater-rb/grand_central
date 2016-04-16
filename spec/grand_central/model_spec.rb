require 'grand_central/model'

module GrandCentral
  describe Model do
    let(:model_class) {
      Class.new(Model) do
        attributes(
          :foo,
          :bar,
          :baz,
        )
      end
    }

    describe :initialize do
      it 'sets attributes' do
        model = model_class.new(foo: 1, bar: 'two')

        expect(model.foo).to eq 1
        expect(model.bar).to eq 'two'
        expect(model.baz).to be_nil
      end
    end

    describe :update do
      it 'returns a copy of the model with the updated attributes' do
        model = model_class.new(foo: 1, bar: 'two')

        new_model = model.update(foo: 2)

        expect(new_model.foo).to eq 2
        expect(new_model.bar).to eq 'two'
      end

      it 'does not mutate the model in place' do
        model = model_class.new(foo: 1)

        model.update foo: 2

        expect(model.foo).to eq 1
      end
    end
  end
end