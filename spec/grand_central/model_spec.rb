require 'grand_central/model'
require 'json'
require 'support/namespace'

module GrandCentral
  describe Model do
    let(:model_class) {
      Class.new(Model) do
        attributes(
          :foo,
          :bar,
          :baz,
          :quux,
        )

        def self.name
          to_s
        end
      end
    }

    describe :initialize do
      it 'sets attributes' do
        model = model_class.new(foo: 1, bar: 'two')

        expect(model.foo).to eq 1
        expect(model.bar).to eq 'two'
        expect(model.baz).to be_nil
      end

      it 'sets attributes with string keys' do
        model = model_class.new('foo' => 1, 'bar' => 'two')

        expect(model.foo).to eq 1
        expect(model.bar).to eq 'two'
        expect(model.baz).to be_nil
      end

      it 'raises a TypeError if the value passed in is not subscriptable' do
        expect {
          model_class.new(nil)
        }.to raise_error(TypeError)
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

      it 'returns the same instance if no modifications are made' do
        model = model_class.new(foo: 1)
        updated = model.update(foo: 1)

        expect(updated).to be model
      end
    end

    describe 'equality' do
      it 'is equal when the attributes are equal' do
        time = Time.now

        one = model_class.new(
          foo: 'omg',
          bar: time,
          baz: 1,
        )

        two = model_class.new(
          foo: 'omg',
          bar: time,
          baz: 1,
        )

        expect(one).to eq two
      end

      it 'is not equal when the attributes do not match' do
        time = Time.now

        one = model_class.new(
          foo: 'lol',
          bar: time,
          baz: 1,
        )

        two = model_class.new(
          foo: 'omg',
          bar: time,
          baz: 1,
        )

        expect(one).not_to eq two
      end
    end

    it 'serializes and deserializes' do
      model_class = self.model_class
      another_model_class = Class.new(GrandCentral::Model) do
        attributes(:zomg, :lol)

        def self.name
          to_s
        end
      end

      namespace = Namespace.new(
        'Time' => Time,
        model_class.name => model_class,
        another_model_class.name => another_model_class,
      )

      one = model_class.new(
        foo: 'lol',
        bar: Time.new(2016, 11, 16, 12, 4, 56),
        baz: 1,
        quux: another_model_class.new(zomg: 1, lol: 'rofl'),
      )

      serialized = one.to_serializable_format
      new_one = Model.deserialize(JSON.parse(serialized.to_json), namespace: namespace)

      expect(new_one).to eq one
    end
  end
end
