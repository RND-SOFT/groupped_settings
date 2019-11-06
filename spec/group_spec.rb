# frozen_string_literal: true

RSpec.describe Groupped::Settings::Group, type: :model do
  class GenericGroup < Groupped::Settings::Group

    self.group_name = 'generic'

    attribute :key1, :integer
    attribute :key2, :string, default: 'def'
    attribute :key3, :string

    validates :key2, length: { is: 3 }

  end

  describe GenericGroup do
    let(:settings){ { key1: 1 } }
    let(:record){ double(Groupped::Settings::Record, settings: settings) }

    subject(:group){ described_class.new(record) }

    it '::attribute_names should be ok' do
      expect(described_class.attribute_names).to match(%w[key1 key2 key3])
    end

    it '::sanitize should transform keys' do
      input = {
        absent_key: '0',
        key1: '1',
        KEY2: '2',
        'KeY3' => '3'
      }

      expect(described_class.sanitize(input)).to match('key1' => '1', 'key2' => '2', 'key3' => '3')
    end

    describe 'instance' do
      before { expect(record).to receive(:settings).and_return(settings) }

      it { expect(described_class).to receive(:sanitize).and_call_original; subject }
      it { is_expected.to include('key1' => 1, 'key2' => 'def', 'key3' => nil) }
      it { is_expected.to be_valid }
      it { expect(group.changes).to be_empty }

      describe '#save!' do
        let(:save){ group.save! }

        before { expect(record).to receive(:with_lock).and_yield }
        before { expect(record).to receive(:save!).and_return(true) }

        it { is_expected.to receive(:validate!).and_call_original; save }
        it { expect(save).to eq(true) }

        it do
          group.key1 = 2
          expect{ save }.to change{ group.changes }.from('key1' => [1, 2]).to({})
        end
      end


      describe '#save' do
        let(:save){ group.save; }

        it ('success is expected to eq true') { is_expected.to receive(:save!).and_return(true); expect(save).to eq(true) }
        it ('exception is expected to eq false'){ is_expected.to receive(:save!).and_raise('error'); expect(save).to eq(false) }
      end

      it '#to_h' do
        expect(group.to_h).to match('key1' => 1, 'key2' => 'def', 'key3' => nil)
      end

      it '#to_hash' do
        expect(group.to_h).to match('key1' => 1, 'key2' => 'def', 'key3' => nil)
      end

      describe 'validation' do
        let(:settings){ { key1: 1, key2: '123123123' } }

        it { is_expected.to include('key1' => 1, 'key2' => '123123123', 'key3' => nil) }
        it { is_expected.not_to be_valid }
        it { expect(group.changes).to be_empty }

        describe '#save!' do
          let(:save){ group.save! }

          it { expect{ save }.to raise_error(ActiveModel::ValidationError) }
        end

        describe '#save' do
          let(:save){ group.save }

          it { expect(save).to eq(false) }
        end
      end
    end
  end
end

