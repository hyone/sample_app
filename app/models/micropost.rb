class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order('created_at DESC') }

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  class << self
    def from_users_followed_by(user)
      # 以下のやり方では、 followed_user が 5000 を越える規模になると,
      # パフォーマンスに問題がでてくる
      # where(
        # 'user_id in (:followed_user_ids) OR user_id = :user_id',
        # followed_user_ids: user.followed_user_ids,
        # user_id: user
      # )

      where <<-EOF, id: user.id
        user_id IN (
          SELECT followed_id FROM relationships WHERE follower_id = :id
        ) OR
        user_id = :id
      EOF
    end
  end
end
