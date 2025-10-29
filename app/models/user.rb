class User < ApplicationRecord
  include EmailVerification, Demoable

  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :splits, dependent: :destroy
  has_many :favourites, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
