require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:category) do
    described_class.create!(name: 'noun')
  end

  context 'when an id is not provided during creation' do
    it 'an id is generated on creation' do
      expect(category.id).to_not be nil
    end

    it 'id is different between instances' do
      category2 = described_class.create!(name: 'verb')
      expect(category.id).to_not eq category2.id
    end
  end

  context 'when an id is provided during creation' do
    let(:my_uuid) { SecureRandom.uuid }
    let(:category2) do
      described_class.create!(
        id: my_uuid,
        name: 'sport'
      )
    end

    it 'an id is not generated on creation' do
      expect(category2.id).to eq my_uuid
    end

    it "if id isn't a valid UUID, one is created" do
      category = described_class.create(
        id: 'bogus-id',
        name: 'household'
      )

      expect(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match?(category.id)).to be true
    end

    it 'id must be unique' do
      category = described_class.create(id: SecureRandom.uuid, name: 'foo')
      expect do
        described_class.create!(id: category.id, name: 'holidays')
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  it "an instance's id cannot be updated" do
    new_id = SecureRandom.uuid
    expect { category.update!(id: new_id) }.to raise_error(
      ActiveRecord::RecordInvalid, "Validation failed: Id can't be updated"
    )
  end

  it 'is searchable by the id' do
    id = category.id
    expect(described_class.find(id)).to eq category
  end

  it 'name uniqueness is enforced' do
    described_class.create(name: 'foo')
    expect do
      described_class.create(name: 'foo')
    end.to change { Category.count }.by(0)
  end
end
