require 'rails_helper'

RSpec.describe WordlistEntry, type: :model do
  let(:wordlist1) { Wordlist.create(user_id: SecureRandom.uuid) }
  let(:word1) { Word.create(name: 'foobar') }
  let(:wordlist_entry) do
    described_class.create!(word_id: word1.id, wordlist_id: wordlist1.id)
  end

  context 'when an id is not provided during creation' do
    it 'an id is generated on creation' do
      expect(wordlist_entry.id).to_not be nil
    end

    it 'id is different between instances' do
      wordlist_entry2 = described_class.create!(
        word_id: Word.create(name: 'fizzbuzz').id,
        wordlist_id: Wordlist.create(user_id: SecureRandom.uuid).id
      )

      expect(wordlist_entry.id).to_not eq wordlist_entry2.id
    end
  end

  context 'when an id is provided during creation' do
    let(:my_uuid) { SecureRandom.uuid }
    let(:wordlist_entry2) do
      described_class.create!(
        id: my_uuid,
        word_id: word1.id,
        wordlist_id: wordlist1.id
      )
    end

    it 'an id is not generated on creation' do
      expect(my_uuid).to eq wordlist_entry2.id
    end

    # how to make this throw instead? All seems to happen at the database level (which doesn't throw when the id isn't
    # a valid uuid)
    it "if id isn't a valid UUID, one is created" do
      wordlist_entry = described_class.create(
        id: 'bogus-id',
        word_id: word1.id,
        wordlist_id: wordlist1.id
      )

      expect(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match?(wordlist_entry.id)).to be true
    end

    it 'id must be unique' do
      expect {
        described_class.create!(
          id: wordlist_entry2.id,
          word_id: word1.id,
          wordlist_id: wordlist1.id
        )
      }.to raise_error(ActiveRecord::RecordNotUnique)
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
end
