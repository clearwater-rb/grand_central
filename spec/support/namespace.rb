module GrandCentral
  class Namespace
    def initialize constants
      @constants = constants
    end

    def const_get const
      @constants.fetch(const.to_s)
    end

    def inspect
      "#<Namespace(#@constants)>"
    end
  end
end
