class Favourite < ApplicationRecord
  belongs_to :user

  def self.owned_by_user(user: Current.user)
    user.favourites
  end
end
