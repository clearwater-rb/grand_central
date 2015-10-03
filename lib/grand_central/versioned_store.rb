require 'grand_central/store'

module GrandCentral
  class VersionedStore < Store
    def initialize *args
      super
      @rollback_versions = []
      @redo_versions = []
    end

    def dispatch *args
      @rollback_versions << state
      @redo_versions.clear
      super
    end

    def rollback
      unless @rollback_versions.empty?
        @redo_versions << (old_state = state)
        @state = @rollback_versions.pop
      end

      run_callbacks old_state, state
    end

    def redo
      unless @redo_versions.empty?
        @rollback_versions << (old_state = state)
        @state = @redo_versions.pop
      end

      run_callbacks old_state, state
    end
  end
end
