class Category < ApplicationRecord
  self.implicit_order_column = 'name' # write a test for this
  has_many :cars
  has_many :wordlist_entries, through: :cars
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
