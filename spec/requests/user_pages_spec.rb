require 'spec_helper'

describe 'UserPages' do
  subject { page }

  describe 'signup page' do
    before { visit signup_path }

    let (:submit_title) { 'Create my account' }

    context 'with invalid information' do
      it 'should not create a user' do
        expect { click_button submit_title }.not_to change(User, :count)
      end
    end

    context 'with valid information' do
      before {
        fill_in 'Name',         with: 'Example User'
        fill_in 'Email',        with: 'user@example.com'
        fill_in 'Password',     with: 'foobar'
        fill_in 'Confirmation', with: 'foobar'
      }

      it 'should create a user' do
        expect { click_button submit_title }.to change(User, :count).by(1)
      end
    end

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe 'profile page' do
    let(:user) { FactoryGirl.create(:user) }

    before {
      visit user_path(user)
    }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end
end
