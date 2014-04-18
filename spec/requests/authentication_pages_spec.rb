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
      before { signin(user) }

      it { should have_link('Users', href: users_path) }

      # in account column
      it { should have_title(user.name) }
      it { should have_profile_link(user) }
      it { should have_settings_link(user) }
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


  describe 'authorization' do
    context 'in a protected page' do
      let (:user) { FactoryGirl.create(:user) }

      context 'with non siginin users' do
        # friendly forwarding
        context 'when attempting to visit a protect page' do
          before {
            visit edit_user_path(user)
            fill_signin_form(user)
            click_signin_button
          }

          context 'after signin' do
            it 'should redirect the original protected page' do
              expect(current_path).to be == edit_user_path(user)
              should have_title('Edit user')
            end
          end
        end

        context 'when visiting the edit page' do
          before { visit edit_user_path(user) }
          it { expect(current_path).to be == signin_path }
        end

        context 'when submitting to the update action' do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end

        context 'when visiting the user index' do
          before { visit users_path }
          it { expect(current_path).to be == signin_path }
        end
      end

      context 'with wrong user' do
        let (:user) { FactoryGirl.create(:user) }
        let (:wrong_user) { FactoryGirl.create(:user, email: 'wrong@example.com') }
        before { signin user, no_capybara: true }

        context 'when submitting a GET request to the Users#edit action' do
          before { get edit_user_path(wrong_user) }

          specify { expect(response.body).not_to match(full_title('Edit user')) }
          specify { expect(response).to redirect_to(root_url) }
        end

        context 'when submitting a PATCH request to the Users#edit action' do
          before { patch user_path(wrong_user) }
          specify { expect(response).to redirect_to(root_path) }
        end
      end

      context 'with non admin user' do
        let (:user) { FactoryGirl.create(:user) }
        let (:non_admin_user) { FactoryGirl.create(:user) }
        before { signin non_admin_user, no_capybara: true }

        context 'when submitting a DELETE reqeust to the Users#destroy action' do
          before { delete user_path(user) }
          specify { expect(response).to redirect_to(root_path) }
        end
      end
    end
  end
end
