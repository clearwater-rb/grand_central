module GrandCentral
  module StoreMixin
    def self.for store
      Module.new do
        define_method(:state) { store.state }
        define_method(:dispatch) { |action| store.dispatch action }

        define_singleton_method :on_dispatch do |&block|
          store.on_dispatch &block
        end
      end
    end
  end
end
