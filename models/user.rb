require "bcrypt"

class User < ActiveRecord::Base
  include BCrypt

  attr_accessor :password, :password_confirmation

  validates :email, presence: true
  validates :email, uniqueness: true
  validates :email, format: {with: /^.+@.+$/, message: "is invalid"}
  validates :password, presence: true
  validates :password, confirmation: true
  validates :password, length: {minimum: 6}
  validates :password_confirmation, presence: true

  before_save :digest

  def valid_password?(password)
    Password.new(self.password_digest) == password
  end

  private

  def digest
    self.password_digest = Password.create(password)
  end
end
