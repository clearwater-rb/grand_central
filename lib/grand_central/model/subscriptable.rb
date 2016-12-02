require "grand_central/model"

module GrandCentral
  class Model
    module Subscriptable
      def merge(other)
        update(other)
      end

      def [](attr)
        send(attr)
      end
    end
  end
end

