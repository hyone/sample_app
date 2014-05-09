require 'spec_helper'
include RequestsHelper


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

      it 'redirect to the user page' do
        expect(current_path).to be == user_path(user)
      end

      context 'followd by signout' do 
        before { click_link 'Sign out' }
        it { should have_link('Sign in') }
      end
    end
  end

  describe 'header content' do
    before { visit signin_path }
    let (:user) { FactoryGirl.create(:user) }

    context 'without signin' do
      it { should_not have_link('Users', href: users_path) }
      # Account tab
      it { should_not have_title(user.name) }
      it { should_not have_profile_link(user) }
      it { should_not have_settings_link(user) }
      it { should_not have_signout_link }
      it { should have_signin_link }
    end

    context 'with signin' do
      before { signin(user) }

      it { should have_link('Users', href: users_path) }
      # Account tab
      it { should have_title(user.name) }
      it { should have_profile_link(user) }
      it { should have_settings_link(user) }
      it { should have_signout_link }
      it { should_not have_signin_link }
    end
  end


  describe 'authorization' do
    context 'in a protected page' do
      let (:user) { FactoryGirl.create(:user) }

      context 'with non siginin users' do
        shared_examples_for 'redirect to signin page' do
          it {
            # capybara
            if current_path
              expect(current_path).to be == signin_path
            # otherwise, from respone that send http request directly
            else
              expect(response).to redirect_to(signin_path)
            end
          }
        end

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

            context 'sigin again without specifying redirect location' do
              before {
                delete signout_path
                signin(user)
              }

              it 'should render the default profile page' do
                expect(page).to have_title(user.name)
              end
            end
          end
        end

        describe 'Users controller' do
          context 'when visiting the new page' do
            before { visit new_user_path }
            specify { expect(current_path).to be == new_user_path }
          end

          context 'when submitting a POST reqeust to the Users#new action' do
            let (:user) { FactoryGirl.build(:user) }
            before { post users_path, user: user.attributes }

            specify { expect(response.status).to be == 200 }
          end

          context 'when visiting the edit page' do
            before { visit edit_user_path(user) }
            it_should_behave_like 'redirect to signin page'
          end

          context 'when submitting to the update action' do
            before { patch user_path(user) }
            it_should_behave_like 'redirect to signin page'
          end

          context 'when visiting the user index' do
            before { visit users_path }
            it_should_behave_like 'redirect to signin page'
          end

          context 'when visiting the following page' do
            before { visit following_user_path(user) }
            it_should_behave_like 'redirect to signin page'
          end

          context 'when visiting the followers page' do
            before { visit followers_user_path(user) }
            it_should_behave_like 'redirect to signin page'
          end
        end

        describe 'Microposts controller' do
          context 'when submitting the create action' do
            before { post microposts_path }
            it_should_behave_like 'redirect to signin page'
          end

          context 'when submitting the destroy action' do
            before {
              micropost = FactoryGirl.create(:micropost)
              delete micropost_path(micropost)
            }
            it_should_behave_like 'redirect to signin page'
          end
        end

        describe 'Relationships controller' do
          context 'when submitting the create action' do
            before { post relationships_path }
            it_should_behave_like 'redirect to signin page'
          end

          context 'when submitting to the destroy action' do
            # hardcoded followed_id
            # because the action should redirect to signin_path before extracting followed_id,
            # so do not use it.
            before { delete relationship_path(1) }
            it_should_behave_like 'redirect to signin page'
          end
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

      context 'with regular user (non admin)' do
        let (:user) { FactoryGirl.create(:user) }
        let (:non_admin_user) { FactoryGirl.create(:user) }

        context 'in pages' do
          before {
            signin(non_admin_user)
          }

          context 'when visiting the new page' do
            before { visit new_user_path }
            specify { expect(current_path).to be == root_path }
          end
        end

        context 'in apis' do
          before { signin non_admin_user, no_capybara: true }

          context 'when submitting a POST reqeust to the Users#new action' do
            let (:new_user) { FactoryGirl.build(:user) }
            before { post users_path, user: new_user.attributes }
            specify { expect(response).to redirect_to(root_path) }
          end

          context 'when submitting a DELETE reqeust to the Users#destroy action' do
            before { delete user_path(user) }
            specify { expect(response).to redirect_to(root_path) }
          end
        end
      end
    end
  end
end
