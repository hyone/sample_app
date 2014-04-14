require 'spec_helper'

describe 'UserPages' do
  subject { page }

  describe 'signup page' do
    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }

    context 'with invalid information' do
      it 'should not create a user' do
        expect { invalid_signup }.not_to change(User, :count)
      end

      context 'after submission' do
        before { invalid_signup }

        it { should have_title('Sign up') }
        it { should have_message(:error, /The form contains.*error(?:s)/) }
      end
    end

    context 'with valid information' do
      let (:user_info) { FactoryGirl.build(:user) }

      it 'should create a user' do
        expect { valid_signup(user_info) }.to change(User, :count).by(1)
      end

      context 'after saving the user' do
        before { valid_signup(user_info) }

        let (:user) { User.find_by(email: user_info.email) }

        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_message(:success, 'Welcome') }
      end
    end
  end

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }

    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end
end
