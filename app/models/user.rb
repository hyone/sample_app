class User < ActiveRecord::Base
  before_save { email.downcase! }
  before_create :create_remember_token

  has_many :microposts, dependent: :destroy

  has_secure_password

  validates :name,  presence: true, length: { maximum: 50 }

  validates :email,
    presence: true,
    format: { with: /\A[\w+\-.]+@(?:[a-z\d\-]+\.)+[a-z]+\z/i },
    uniqueness: { case_sensitive: false }

  validates :password, length: { minimum: 6 }


  class << self
    def new_remember_token
      SecureRandom.urlsafe_base64
    end

    def encrypt(token)
      Digest::SHA1.hexdigest(token.to_s)
    end
  end

  def feed
    Micropost.where('user_id = ?', id)
  end

  private
  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end
end
