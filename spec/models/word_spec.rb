require 'rails_helper'

RSpec.describe Word, type: :model do
  let(:word) do
    described_class.create!(name: 'table')
  end

  context 'when an id is not provided during creation' do
    it 'an id is generated on creation' do
      expect(word.id).to_not be nil
    end

    it 'id is different between instances' do
      word2 = described_class.create!(name: 'hound')
      expect(word.id).to_not eq word2.id
    end

    it 'cannot be saved without a name' do
      expect do
        described_class.create!
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
    end
  end

  context 'when an id is provided during creation' do
    let(:uuid) { '79c9bc0f-8ecf-4cf7-a05e-7c485d02078d' }
    let(:word2) { described_class.create!(id: uuid, name: 'banshee') }

    it 'is given the provided id' do
      expect(word2.id).to eq '79c9bc0f-8ecf-4cf7-a05e-7c485d02078d'
    end

    it "if id isn't a valid UUID, one is created" do
      w = described_class.create!(id: 'bogus-id', name: 'baskerville')
      expect(VALID_UUID_REGEX.match?(w.id)).to be true
    end

    it 'id must be unique' do
      expect do
        described_class.create!(id: word2.id, name: 'dawg')
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'cannot be saved without a name' do
      expect do
        described_class.create!(id: SecureRandom.uuid)
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name can't be blank")
    end
  end

  it "an instance's id cannot be updated" do
    expect { word.update!(id: SecureRandom.uuid) }.to raise_error(
      ActiveRecord::RecordInvalid, "Validation failed: Id can't be updated"
    )
  end

  it 'is searchable by the id' do
    expect(described_class.find(word.id)).to eq(word)
  end
end
