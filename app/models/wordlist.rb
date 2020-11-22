class Wordlist < ApplicationRecord
  self.implicit_order_column = 'created_at'
  has_many :wordlist_entries
  has_many :words, through: :wordlist_entries
  validate :id_not_changed
  validates :user_id, presence: true
  validates_uniqueness_of :user_id

  private

  def id_not_changed
    return unless id_changed? && persisted?

    errors.add(:id, "can't be updated")
  end
end
