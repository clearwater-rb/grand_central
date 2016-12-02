require 'spec_helper'
require "grand_central/model/subscriptable"

module GrandCentral
  class Model
    describe Subscriptable do
      let(:model_class) {
        Class.new(Model) do
          include Subscriptable
          attributes :foo
        end
      }

      it "allows attributes to be accessed via subscript operator" do
        model = model_class.new(foo: 1)

        expect(model[:foo]).to eq(1)
      end

      it "behaves a little hash-ier by aliasing update to merge" do
        model = model_class.new(foo: 1)
        new_model = model.merge(foo: "bar")

        expect(new_model.foo).to eq("bar")
      end
    end
  end
end
