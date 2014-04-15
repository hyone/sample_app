require 'spec_helper'

describe "AuthenticationPages" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    context 'with invalid info' do
      before { click_button 'Sign in' }

      it { should have_content('Sign in') }
      it { should have_message(:error, 'Invalid') }

      context 'after visiting another page' do
        before { click_link 'Home' }

        it { should_not have_message(:error, 'error') }
      end
    end

    context 'with valid info' do
      let (:user) { FactoryGirl.create(:user) }

      before {
        valid_signin(user)
      }

      it { should have_title(user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_signout_link }
      it { should_not have_signin_link }

      context 'followd by signout' do 
        before {
          click_link 'Sign out'
        }
        it { should have_link('Sign in') }
      end
    end
  end
end
