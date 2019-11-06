# frozen_string_literal: true

RSpec.describe Groupped::Settings, type: :model do
  describe '#[]' do
    let(:group){ :test }
    subject{ described_class[group] }

    it { is_expected.to be_an(Groupped::Settings::Group) }
    it {
      expect{ subject }.to change{ Groupped::Settings::Record.where(group: group).count }
        .from(0)
        .to(1)
    }
  end

  class TestGroup1 < Groupped::Settings::Group

    self.group_name = :test1

    attribute :key1, :integer
    attribute :key2, :string, default: 'def'

    validates :key2, length: { is: 3 }

  end

  class TestGroup2 < Groupped::Settings::Group

    self.group_name = :test2

    attribute :yek1, :datetime, default: 10.years.ago
    attribute :yek2, :string

    validates :yek2, presence: true

  end

  groups = { test1: TestGroup1, test2: TestGroup2 }

  describe 'control' do
    groups.each do |(group, klass)|
      describe "group: #{group} -> #{klass}" do
        it { expect(klass.group_name).to eq(group) }

        it { expect(Groupped::Settings[group]).to be_an(Groupped::Settings::Group) }
        it { expect(Groupped::Settings[:test1, klass]).to be_an(klass) }
        it { expect(Groupped::Settings[:test1, klass].group_name).to eq(group) }
        it { expect(klass.load).to be_an(klass) }
        it { expect(klass.load.group_name).to eq(group) }
      end
    end
  end

  it 'huge integration' do
    expect(Groupped::Settings::Record.count).to eq(0)

    # groups.each do
    s = TestGroup1.load
    expect(s.changes).to be_empty
    expect(s).to include('key1' => nil, 'key2' => 'def')
    expect(Groupped::Settings::Record.count).to eq(1)
    expect(Groupped::Settings::Record.find_by_group(:test1).settings).to match({})

    s.save!
    expect(s.changes).to be_empty
    expect(s).to include('key1' => nil, 'key2' => 'def')
    expect(Groupped::Settings::Record.count).to eq(1)
    expect(Groupped::Settings::Record.find_by_group(:test1).settings).to match({})

    s.key1 = 123
    expect(s.changes).not_to be_empty
    expect(s).to include('key1' => 123, 'key2' => 'def')
    s.save!
    expect(Groupped::Settings::Record.count).to eq(1)
    expect(Groupped::Settings::Record.find_by_group(:test1).settings).to match('key1' => 123)

    s = TestGroup1.load
    expect(s.changes).to be_empty
    expect(s).to include('key1' => 123, 'key2' => 'def')
    expect(Groupped::Settings::Record.count).to eq(1)
    expect(Groupped::Settings::Record.find_by_group(:test1).settings).to match('key1' => 123)

    # handle missing keys
    r = Groupped::Settings::Record.find_by_group(:test1)
    r.settings[:absent] = true
    r.save!

    s = TestGroup1.load
    expect(s.changes).to be_empty
    expect(s).to include('key1' => 123, 'key2' => 'def')
    expect(Groupped::Settings::Record.count).to eq(1)
    expect(Groupped::Settings::Record.find_by_group(:test1).settings).to match('key1' => 123, 'absent' => true)

    s2 = TestGroup1.load

    s.key1 = 321
    s2.key2 = 'tes'
    s2.save!

    expect(Groupped::Settings::Record.find_by_group(:test1).settings).to match('key1' => 123, 'absent' => true, 'key2' => 'tes')
    s.save!
    expect(Groupped::Settings::Record.find_by_group(:test1).settings).to match('key1' => 321, 'absent' => true, 'key2' => 'tes')

    s1 = TestGroup1.load
    s2 = TestGroup1.load

    expect(s1).to match(s2)

    s1.key1 = 543
    expect(s1).not_to match(s2)
  end

  describe 'with target' do
    let!(:user){ User.create! }
    before do
      User.include Groupped::Settings::Settingsable
    end

    it do
      expect(user.groupped_settings.count).to eq(0)
      s = user.settings_group(:base)
      expect(user.groupped_settings.count).to eq(1)

      s = user.settings_group(:base, TestGroup1)
      s.key1 = 777
      s.save
      expect(user.groupped_settings.count).to eq(1)
      expect(user.groupped_settings.first.settings).to match('key1' => 777)
    end
  end
end

