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
    end
  end
end
