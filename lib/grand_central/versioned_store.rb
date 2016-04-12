require 'grand_central/store'

module GrandCentral
  class VersionedStore < Store
    attr_reader :current_version

    def initialize *args
      super

      @current_version = 0
      @rollback_versions = []
      @redo_versions = []
    end

    def dispatch *args
      old_state = state

      result = super

      @rollback_versions << old_state
      @redo_versions.clear
      @current_version += 1

      result
    end

    def rollback
      unless @rollback_versions.empty?
        @redo_versions << (old_state = state)
        @state = @rollback_versions.pop
        @current_version -= 1
      end

      run_callbacks old_state, state
    end

    def redo
      unless @redo_versions.empty?
        @rollback_versions << (old_state = state)
        @state = @redo_versions.pop
        @current_version += 1
      end

      run_callbacks old_state, state
    end

    def total_versions
      @rollback_versions.size + @redo_versions.size + 1
    end

    def go_to_version version
      while version > current_version
        self.redo
      end
      while version < current_version
        rollback
      end
    end

    def commit!
      initialize state
    end
  end
end
