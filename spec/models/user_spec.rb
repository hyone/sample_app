require 'spec_helper'


describe User do
  before {
    @user = User.new(
      name: "Example User",
      email: "user@example.com",
      password: 'foobar',
      password_confirmation: 'foobar'
    )
  }

  subject { @user }

  it "original user should be valid" do
    should be_valid
  end


  describe 'name' do
    it { should respond_to(:name) }

    context 'when not present' do
      before {
        @user.name = ' '
      }

      it { should be_invalid }
    end

    context 'when too long' do
      before {
        @user.name = 'a' * 51
      }

      it { should be_invalid }
    end
  end


  describe 'email' do
    it { should respond_to(:email) }

    context 'when not present' do
      before {
        @user.email = '  '
      }

      it { should be_invalid }
    end

    context 'when format is invalid' do
      it 'be invalid' do
        addresses = %w{
          user@foo,com
          user_at_foo.org
          example.user@foo.
          foo@bar_baz.com
          foo@bar+baz.com
          foo@bar..com 
        }
        addresses.each do |invalid_address|
          @user.email = invalid_address
          expect(@user).to be_invalid
        end
      end
    end

    context 'when format is valid' do
      it 'be valid' do
        addresses = %w{
          user@foo.COM
          A_US-ER@f.b.org
          frst.lst@foo.jp
          a+b@baz.cn
        }
        addresses.each do |valid_address|
          @user.email = valid_address
          expect(@user).to be_valid
        end
      end
    end

    context 'when be already taken' do
      before {
        user_with_same_email = @user.dup
        user_with_same_email.save
      }

      it { should be_invalid }
    end

    context 'with mixed case' do
      let (:mixed_case_email) { 'Foo@ExAMPle.CoM' }

      before {
        @user.email = mixed_case_email
        @user.save
      }

      it 'be saved as all lower-case' do
        @user.reload
        expect(@user.email).to eq mixed_case_email.downcase
      end
    end
  end


  describe 'password' do
    it { should respond_to(:password_digest) }
    it { should respond_to(:password) }
    it { should respond_to(:password_confirmation) }
    it { should respond_to(:authenticate) }

    context 'when not present' do
      before {
        @user = User.new(
          name: 'Example User',
          email: 'user@example.com',
          password: ' ',
          password_confirmation: ' '
        )
      }

      it { should be_invalid }
    end

    context "when doesn't match confirmation" do
      before {
        @user.password_confirmation = 'mismatch'
      }

      it { should be_invalid }
    end
  end


  describe 'authenticate' do
    # save before execute 'User.find_by' to guarantee @user has persisted to database
    before { @user.save }

    let (:found_user) {
      User.find_by(email: @user.email)
    }

    context 'with valid password' do
      it { should eq found_user.authenticate(@user.password) }
    end

    context 'with invalid password' do
      let (:user_for_invalid_password) { found_user.authenticate('invalid') }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end


  describe 'remember_token' do
    before { @user.save }

    it { should respond_to(:remember_token) }
    its (:remember_token) { should_not be_blank }
  end


  describe 'admin' do
    it { should respond_to(:admin) }

    context 'with admin attribute "true"' do
      before {
        @user.save!
        @user.toggle!(:admin)
      }

      it { should be_admin }
    end
  end


  # has_many
  describe 'microposts' do
    it { should respond_to(:microposts) }

    context 'association' do
      before { @user.save }

      let! (:micropost1) {
        FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
      }
      let! (:micropost2) {
        FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
      }
      let! (:micropost3) {
        FactoryGirl.create(:micropost, user: @user, created_at: 3.hour.ago)
      }

      it 'should have the right microposts in the right order' do
        expect(@user.microposts.to_a).to eq [micropost2, micropost3, micropost1]
      end

      context 'when user has deleted' do
        it 'should also remove all associated microposts' do
          # 'to_a' method creates a copy of the micropost objects
          microposts = @user.microposts.to_a

          @user.destroy
          expect(microposts).not_to be_empty

          microposts.each do |micropost|
            expect(Micropost.where(id: micropost.id)).to be_empty
          end
        end
      end
    end
  end


  # has_many
  describe 'relationships' do
    it { should respond_to(:relationships) }
  end

  describe 'followed_users' do
    it { should respond_to(:followed_users) }
  end

  describe 'following?' do
    it { should respond_to(:following?) }
  end

  describe 'follow!' do
    it { should respond_to(:follow!) }
  end

  describe 'unfollow!' do
    it { should respond_to(:unfollow!) }
  end

  describe 'followers' do
    it { should respond_to(:followers) }
  end

  context 'about follow' do
    let (:other_user) { FactoryGirl.create(:user) }
    before {
      @user.save
      @user.follow!(other_user)
    }

    context 'when following' do
      it { should be_following(other_user) }
      its (:followed_users) { should include(other_user) }
    end

    context 'then unfollowing' do
      before { @user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      its (:followed_users) { should_not include(other_user) }
    end

    context 'From follower' do
      subject { other_user }
      its (:followers) { should include(@user) }
    end
  end


  describe 'feed' do
    before { @user.save }

    let! (:micropost1) {
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    }
    let! (:micropost2) {
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    }
    let! (:unfollowd_post) {
      FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
    }
    let (:followed_user) { FactoryGirl.create(:user) }

    before {
      @user.follow!(followed_user)
      3.times { followed_user.microposts.create!(content: 'Lorem ipsum') }
    }

    its(:feed) { should include(micropost1) }
    its(:feed) { should include(micropost2) }
    its(:feed) { should_not include(unfollowd_post) }
    its(:feed) {
      followed_user.microposts.each do |micropost|
        should include(micropost)
      end
    }
  end

end
