class ReviewJournal < ActiveRecord::Base
  attr_accessible :description, :link, :name, :user_ids, :protect_id
  has_and_belongs_to_many :users

#  accepts_nested_attributes_for :users, allow_destroy: true

  def is_reviewer?(user_p)
    !user_p.nil? && !users.find_by_id(user_p.id).nil?
  end
end
