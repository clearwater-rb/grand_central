require 'grand_central/versioned_store'

module GrandCentral
  describe VersionedStore do
    let(:store) {
      GrandCentral::VersionedStore.new(0) do |state, action|
        case action
        when :increment
          state + 1
        when :decrement
          state - 1
        else
          state
        end
      end
    }

    context 'on dispatch' do
      it 'clears the redo cache' do
        store.dispatch :increment
        store.rollback
        store.dispatch :decrement

        expect { store.redo }.not_to change { store.state }
      end

      it 'increments the version' do
        expect(store.current_version).to eq 0

        store.dispatch :increment
        expect(store.current_version).to eq 1

        store.dispatch :increment
        expect(store.current_version).to eq 2
      end
    end

    context 'on rollback' do
      it 'returns to the previous version' do
        current = store.state
        store.dispatch :increment
        store.rollback
        expect(store.state).to be current
      end

      it 'calls on_dispatch hooks' do
        store.dispatch :increment
        foo = 0
        store.on_dispatch { foo = 1 }
        store.rollback

        expect(foo).to be 1
      end

      it 'does not change state if there is nothing to rollback to' do
        expect { store.rollback }.not_to change { store.state }
      end

      it 'decrements the version' do
        3.times do
          store.dispatch :increment
        end

        store.rollback
        expect(store.current_version).to eq 2

        store.rollback
        expect(store.current_version).to eq 1
      end
    end

    context 'on redo' do
      it 'returns to the next version' do
        store.dispatch :increment
        current = store.state

        store.rollback
        store.redo

        expect(store.state).to be current
      end

      it 'runs on_dispatch callbacks' do
        store.dispatch :increment
        store.rollback
        foo = 0
        store.on_dispatch { foo = 1 }

        store.redo

        expect(foo).to be 1
      end

      it 'does not change state if there is nothing to redo' do
        store.dispatch :increment
        store.rollback
        store.redo

        expect { store.redo }.not_to change { store.state }
      end

      it 'adds the current state back to be rollbackable' do
        store.dispatch :increment
        store.dispatch :increment
        store.rollback
        current = store.state

        store.redo
        store.rollback

        expect(store.state).to be current
      end

      it 'increments the current version' do
        store.dispatch :increment

        store.rollback
        store.redo

        expect(store.current_version).to eq 1
      end
    end

    it 'tracks total versions' do
      3.times do
        store.dispatch :increment
      end
      store.rollback

      # Initial state + 3 dispatches = 4 versions
      expect(store.total_versions).to eq 4
    end

    it 'can go to a specific version' do
      3.times do
        store.dispatch :increment
      end

      store.go_to_version 1
      expect(store.current_version).to eq 1
      expect(store.state).to eq 1

      store.go_to_version 2
      expect(store.current_version).to eq 2
      expect(store.state).to eq 2
    end

    it 'commits to the current version' do
      3.times do
        store.dispatch :increment
      end

      store.commit!
      expect(store.total_versions).to eq 1
      expect(store.current_version).to eq 0
    end
  end
end
