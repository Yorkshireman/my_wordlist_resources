require 'rails_helper'

RSpec.describe Wordlist, type: :model do
  let(:wordlist) { described_class.create!(user_id: SecureRandom.uuid) }

  context 'when an id is not provided during creation' do
    it 'an id is generated on creation' do
      expect(wordlist.id).to_not be_nil
    end

    it 'id is different between instances' do
      wordlist2 = described_class.create!(user_id: SecureRandom.uuid)
      expect(wordlist.id).to_not eq wordlist2.id
    end

    it 'cannot be saved if user_id already has a Wordlist associated with it' do
      expect do
        described_class.create!(user_id: wordlist.user_id)
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: User has already been taken')
    end
  end

  context 'when an id is provided during creation' do
    let(:uuid) { '79c9bc0f-8ecf-4cf7-a05e-7c485d02078d' }
    let(:wordlist2) { described_class.create!(id: uuid, user_id: SecureRandom.uuid) }

    it 'is given the provided id' do
      expect(wordlist2.id).to eq '79c9bc0f-8ecf-4cf7-a05e-7c485d02078d'
    end

    it "if id isn't a valid UUID, one is created" do
      wl = described_class.create!(id: 'bogus-id', user_id: SecureRandom.uuid)
      expect(VALID_UUID_REGEX.match?(wl.id)).to be true
    end

    it 'id must be unique' do
      expect do
        described_class.create!(id: wordlist2.id, user_id: SecureRandom.uuid)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'cannot be saved without a user_id' do
      expect do
        described_class.create!(id: SecureRandom.uuid)
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: User can't be blank")
    end

    it 'cannot be saved if user_id already has a Wordlist associated with it' do
      expect do
        described_class.create!(user_id: wordlist2.user_id)
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: User has already been taken')
    end
  end

  it "an instance's id cannot be updated" do
    expect { wordlist.update!(id: SecureRandom.uuid) }.to raise_error(
      ActiveRecord::RecordInvalid, "Validation failed: Id can't be updated"
    )
  end

  it 'is searchable by the id' do
    expect(described_class.find(wordlist.id)).to eq(wordlist)
  end
end
