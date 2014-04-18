require 'spec_helper'

describe 'UserPages' do
  subject { page }

    describe 'index page' do
      before {
        user = FactoryGirl.create(:user)
        FactoryGirl.create(:user, name: 'Bob', email: 'bob@example.com')
        FactoryGirl.create(:user, name: 'Ben', email: 'ben@example.com')
        signin user
        visit users_path
      }

      describe 'content' do
        it { should have_title('All users') }
        it { should have_content('All users') }
      end

      describe 'pagination' do
        before(:all) {
          50.times { FactoryGirl.create(:user) }
        }
        after(:all) {
          User.delete_all
        }

        it { should have_selector('div.pagination') }

        it 'should list each user in page 1' do
          User.paginate(page: 1).each do |user|
            expect(page).to have_selector('li', text: user.name)
          end
        end
      end

      describe 'delete links' do
        context 'with non admin user' do
          it { should_not have_link('delete') }
        end

        context 'with admin user ' do
          let (:admin) { FactoryGirl.create(:admin) }
          before {
            signin admin
            visit users_path
          }

          it { should have_link('delete', href: user_path(User.first)) }
          it { should_not have_link('delete', href: user_path(admin)) }

          it 'should be able to delete another user' do
            expect {
              click_link('delete', match: :first)
            }.to change(User, :count).by(-1)
          end
        end
      end

    end

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
        expect { signup(user_info) }.to change(User, :count).by(1)
      end

      context 'after saving the user' do
        before { signup(user_info) }

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


  describe 'edit page' do
    let (:user) { FactoryGirl.create(:user) }
    before {
      signin user
      visit edit_user_path(user)
    }

    describe 'content' do
      it { should have_content('Update your profile') }
      it { should have_title('Edit user') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end

    context 'with invalid info' do
      before { click_button 'Save changes' }

      it { should have_message(:error, 'error') }
    end

    context 'with valid info' do
      let (:user) { FactoryGirl.create(:user) }
      let (:new_user) { FactoryGirl.build(:user, name: 'New Name', email: 'new@example.com' ) }
      before {
        fill_userinfo_form(new_user)
        click_button 'Save changes'
      }

      it { should have_title(new_user.name) }
      it { should have_message(:success) }
      it { should have_signout_link }
      specify { expect(user.reload.name).to  eq new_user.name }
      specify { expect(user.reload.email).to eq new_user.email }
    end
  end
end
