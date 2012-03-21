class Doc < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :name
  validates_uniqueness_of :name, scope: :user_id
end
