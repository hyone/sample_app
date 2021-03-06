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

  it "original user is valid" do
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

end
