require 'rails_helper'

RSpec.describe WordlistEntry, type: :model do
  let(:category1) { create(:category) }
  let(:category2) { create(:category) }
  let(:wordlist) { create(:wordlist) }
  let(:word) { create(:word) }
  let(:wordlist_entry) do
    described_class.create!(word_id: word.id, wordlist_id: wordlist.id)
  end

  context 'when an id is not provided during creation' do
    it 'an id is generated on creation' do
      expect(wordlist_entry.id).to_not be nil
    end

    it 'id is different between instances' do
      wordlist_entry2 = create(:wordlist_entry)
      expect(wordlist_entry.id).to_not eq wordlist_entry2.id
    end
  end

  context 'when an id is provided during creation' do
    let(:uuid) { '79c9bc0f-8ecf-4cf7-a05e-7c485d02078d' }
    let(:wordlist_entry2) do
      described_class.create!(
        id: uuid,
        word_id: word.id,
        wordlist_id: wordlist.id
      )
    end

    it 'an id is not generated on creation' do
      expect(wordlist_entry2.id).to eq '79c9bc0f-8ecf-4cf7-a05e-7c485d02078d'
    end

    it "if id isn't a valid UUID, one is created" do
      wle = described_class.create(
        id: 'bogus-id',
        word_id: word.id,
        wordlist_id: wordlist.id
      )

      expect(VALID_UUID_REGEX.match?(wle.id)).to be true
    end

    it 'id must be unique' do
      expect do
        described_class.create!(
          id: wordlist_entry2.id,
          word_id: create(:word).id,
          wordlist_id: wordlist.id
        )
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  it "an instance's id cannot be updated" do
    expect { wordlist_entry.update!(id: SecureRandom.uuid) }.to raise_error(
      ActiveRecord::RecordInvalid, "Validation failed: Id can't be updated"
    )
  end

  it 'is searchable by the id' do
    id = wordlist_entry.id
    expect(described_class.find(id)).to eq wordlist_entry
  end

  it 'can add a category' do
    wordlist_entry.categories << category1
    expect(wordlist_entry.categories).to eq([category1])
  end

  it 'cannot add same category twice' do
    wordlist_entry.categories << category1
    expect { wordlist_entry.categories << category1 }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'can add a category that already belongs to another WordlistEntry' do
    wordlist_entry2 = create(:wordlist_entry)
    wordlist_entry2.categories << category1

    wordlist_entry.categories << category1
    expect(wordlist_entry.categories).to eq([category1])
  end
end
