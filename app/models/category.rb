class Category < ApplicationRecord
  self.implicit_order_column = 'created_at'
  has_and_belongs_to_many :wordlist_entries
  has_many :words, through: :wordlist_entries
  validate :id_not_changed
  validates :name, presence: true
  validates_uniqueness_of :name

  private

  def id_not_changed
    return unless id_changed? && persisted?

    errors.add(:id, "can't be updated")
  end
end
