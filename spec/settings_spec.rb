# frozen_string_literal: true

RSpec.describe 'GrouppedSettings::Setting', type: :model do
  class GenericGroup < GrouppedSettings::Group
    attribute :key1, :integer
    attribute :key2, :string, default: 'def'
    attribute :key3, :string

    validates :key2, length: { is: 3 }
  end

  it '#[]' do
    expect(GrouppedSettings::Setting[:generic]).to be_an(GenericGroup)
  end

  describe GenericGroup do
    subject(:klass) { described_class }

    it ("#group_name match #{described_class}") { expect(subject.group_name).to eq('generic') }
    it ("#group_class match #{described_class}") { expect(subject.group_class(:generic)).to eq(described_class) }
    it ('#attribute_names be ok') { expect(subject.attribute_names).to eq(%w[key1 key2 key3]) }
    describe '#load' do
      subject(:load) { klass.load }
      it { is_expected.to be_an(described_class) }
      it { is_expected.to be_valid }
      it { is_expected.to include('key1' => nil, 'key2' => 'def', 'key3' => nil) }
    end

    it ('#to_group_key be ok') { expect(subject.to_group_key('key1')).to eq('generic.key1') }
    it ('#from_group_key be ok') { expect(subject.from_group_key('generic.key1')).to eq('key1') }
  end

  describe 'initialization' do
    subject(:group) { GenericGroup.new }

    describe 'default' do
      it { is_expected.to be_valid }
      it { is_expected.to include('key1' => nil, 'key2' => 'def', 'key3' => nil) }

      describe 'changes' do
        subject(:changes) { group.changes }
        it { is_expected.to be_empty }
      end

      describe 'save!' do
        subject(:save) { group.save! }

        it { expect { save }.not_to change { GrouppedSettings::Setting.count } }
        it { is_expected.to be true }
      end
    end

    describe 'key assignment' do
      before { group.key3 = 'test' }

      it { is_expected.to be_valid }
      it { is_expected.to include('key1' => nil, 'key2' => 'def', 'key3' => 'test') }

      describe 'changes' do
        subject(:changes) { group.changes }
        it { is_expected.not_to be_empty }
        it { is_expected.to match('key3' => [nil, 'test']) }
      end

      describe 'reload' do
        subject(:reload) { group.reload }

        it 'is expected to reset changes' do
          expect { reload }.to change { group.changes }.from('key3' => [nil, 'test']).to({})
        end
      end

      describe 'save!' do
        subject(:save) { group.save! }

        it { expect { save }.to change { GrouppedSettings::Setting.count }.from(0).to(1) }
        it { is_expected.to be true }

        it 'is expected to reset changes' do
          expect { save }.to change { group.changes }.from('key3' => [nil, 'test']).to({})
        end
      end
    end

    describe 'validation' do
      before { group.key2 = 'defdef' }
      it { is_expected.to be_invalid }

      describe 'save' do
        subject(:save) { group.save }

        it { is_expected.to be false }
        it { expect { save }.not_to raise_exception }
      end

      describe 'save!' do
        subject(:save) { group.save! }

        it { expect { save }.to raise_exception(ActiveModel::ValidationError) }
      end
    end
  end

  describe 'loading' do
    subject(:group) { GenericGroup.load }
    before do
      GenericGroup.new.tap do |g|
        g.key1 = 321
        g.save!
      end
    end

    describe 'key read force reload' do
      subject(:group) { GenericGroup.new }
      it do
        expect { group.reload }.to change { group.attributes }
          .from('key1' => nil, 'key2' => 'def', 'key3' => nil)
          .to('key1' => 321, 'key2' => 'def', 'key3' => nil)
      end
    end

    describe 'default' do
      it { is_expected.to be_valid }
      it { is_expected.to include('key1' => 321, 'key2' => 'def', 'key3' => nil) }

      describe 'changes' do
        subject(:changes) { group.changes }
        it { is_expected.to be_empty }
      end

      describe 'save!' do
        subject(:save) { group.save! }

        it { expect { save }.not_to change { GrouppedSettings::Setting.count } }
        it { is_expected.to be true }
      end
    end

    describe 'key assignment' do
      before { group.key3 = 'test' }

      it { is_expected.to be_valid }
      it { is_expected.to include('key1' => 321, 'key2' => 'def', 'key3' => 'test') }

      describe 'changes' do
        subject(:changes) { group.changes }
        it { is_expected.not_to be_empty }
        it { is_expected.to match('key3' => [nil, 'test']) }
      end

      describe 'reload' do
        subject(:reload) { group.reload }

        it 'is expected to reset changes' do
          expect { reload }.to change { group.changes }.from('key3' => [nil, 'test']).to({})
        end
      end

      describe 'save!' do
        subject(:save) { group.save! }

        it { expect { save }.to change { GrouppedSettings::Setting.count }.from(1).to(2) }
        it { is_expected.to be true }

        it 'is expected to reset changes' do
          expect { save }.to change { group.changes }.from('key3' => [nil, 'test']).to({})
        end
      end

      describe '[] from Setting' do
        subject(:dynamic) { GrouppedSettings::Setting[:generic] }
        it { is_expected.to eq(group.reload) }
      end
    end
  end
end
