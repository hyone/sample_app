require 'spec_helper'

describe User do
  before {
    @user = User.new(
      name: 'Example User',
      email: 'user@example.com',
      password: 'foobar',
      password_confirmation: 'foobar'
    )
  }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  context 'when name is not present' do
    before { @user.name = ' ' }

    it { should_not be_valid }
  end

  context 'when email is not present' do
    before { @user.email = ' ' }

    it { should_not be_valid }
  end

  context 'when name is too long' do
    before { @user.name = 'a' * 51 }

    it { should_not be_valid }
  end

  context 'when email format is invalid' do
    it "be invalid" do
      addresses = %w[
        user@foo,com
        user_at_foo.org
        example.user@foo.
        foo@bar_baz.com
        foo@bar+baz.com
        foo@bar..com
      ]

      addresses.each do |invalid_address|
        @user.email = invalid_address
        should_not be_valid
      end
    end
  end

  context 'when email format is valid' do
    it "should be valid" do
      addresses = %w[
        user@foo.COM
        A_US-ER@f.b.org
        frst.lst@foo.jp
        a+b@baz.cn
      ]
      addresses.each do |valid_address|
        @user.email = valid_address
        should be_valid
      end
    end
  end

  context 'when email address is already taken' do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email.upcase!
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  context 'when password is not present' do
    before {
      @user = User.new(
        name: 'Example User',
        email: 'user@example.com',
        password: ' ',
        password_confirmation: ' '
      )
    }

    it { should_not be_valid }
  end

  context "with a password that's too shoot" do
    before {
      @user.password = @user.password_confirmation = 'a' * 5
    }

    it { should be_invalid }
  end

  context "when password doesn't match confirmation" do
    before {
      @user.password_confirmation = 'mismatch'
    }

    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let (:found_user) { User.find_by(email: @user.email) }

    context 'with valid password' do
      it { should eq found_user.authenticate(@user.password) }
    end

    context 'with invalid password' do
      let (:user_for_invalid_password) { found_user.authenticate('invalid') }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end
end
