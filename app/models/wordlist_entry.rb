class WordlistEntry < ApplicationRecord
  self.implicit_order_column = 'created_at'

  belongs_to :word
  belongs_to :wordlist
  has_many :word_categories
  has_many :categories, through: :word_categories

  validate :id_not_changed
  validates :word_id, presence: true
  validates :wordlist_id, presence: true

  private

  def id_not_changed
    return unless id_changed? && persisted?

    errors.add(:id, "can't be updated")
  end
end
