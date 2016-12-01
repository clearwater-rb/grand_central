require "grand_central/model"

module GrandCentral
  class Model
    module Subscriptable
      def self.included(base)
        base.send(:alias_method, :merge, :update)
      end

      def [](attr)
        send(attr)
      end
    end
  end
end

