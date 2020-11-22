class Word < ApplicationRecord
  self.implicit_order_column = 'created_at'
  has_many :categories, through: :wordlist_entries
  has_many :wordlist_entries
  has_many :wordlists, through: :wordlist_entries
  validate :id_not_changed
  validates :name, presence: true
  validates_uniqueness_of :name

  private

  def id_not_changed
    return unless id_changed? && persisted?

    errors.add(:id, "can't be updated")
  end
end
