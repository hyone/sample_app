require 'spec_helper'
include RequestsHelper


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

        it 'should not be able to delete myself' do
          expect {
            signin admin, no_capybara: true
            delete user_path(admin)
          }.not_to change(User, :count)
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
    let (:user) { FactoryGirl.create(:user) }
    let! (:m1) { FactoryGirl.create(:micropost, user: user, content: 'Foo') }
    let! (:m2) { FactoryGirl.create(:micropost, user: user, content: 'Bar') }

    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }

    describe 'microposts' do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user.microposts.count) }

      context 'about pagination' do
        before {
          50.times { |i| FactoryGirl.create(:micropost, user: user) }
          visit user_path(user)
        }

        it { should have_selector('div.pagination') }

        it 'should list each micropost in page 1' do
          user.microposts.paginate(page: 1).each do |micropost|
            expect(page).to have_selector('li', text: micropost.content)
          end
        end
      end
    end

    describe 'follow/unfollow buttons' do
      let (:other_user) { FactoryGirl.create(:user) }
      before { signin user }

      context 'when click follow button' do
        before { visit user_path(other_user) }

        it "should increment the followed user count" do
          expect { click_button 'Follow' }.to change(user.followed_users, :count).by(1)
        end

        it "should increment the other user's followers count" do
          expect { click_button 'Follow' }.to change(other_user.followers, :count).by(1)
        end

        context 'after click follow button' do
          before { click_button 'Follow' }

          it 'should toggle to unfollow button' do
            should have_xpath("//input[@value='Unfollow']")
          end
        end
      end

      context 'when click unfollow button' do
        before {
          user.follow!(other_user)
          visit user_path(other_user)
        }

        it 'should decrement the followed user count' do
          expect { click_button 'Unfollow' }.to change(user.followed_users, :count).by(-1)
        end

        it "should decrement the other user's followers count" do
          expect { click_button 'Unfollow' }.to change(other_user.followers, :count).by(-1)
        end

        context 'after click unfollow button' do
          before { click_button 'Unfollow' }

          it 'should toggle to unfollow button' do
            should have_xpath("//input[@value='Follow']")
          end
        end
      end
    end
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

    context 'with forbidden attributes' do
      let (:params) {
        {
          user: {
            admin: true,
            password: user.password,
            password_confirmation: user.password
          }
        }
      }
      before {
        signin user, no_capybara: true
        patch user_path(user), params
      }

      specify {
        expect(user.reload).not_to be_admin
      }
    end
  end


  describe 'following/follower page' do
    let (:user)  { FactoryGirl.create(:user) }
    let (:other_user) { FactoryGirl.create(:user) }
    before { user.follow!(other_user) }

    context 'about followed users' do
      before {
        signin user
        visit following_user_path(user)
      }

      it { should have_title(full_title('Following')) }
      it { should have_selector('h3', text: 'Following') }
      it { should have_link(other_user.name, href: user_path(other_user)) }
    end

    context 'about followers' do
      before {
        signin other_user
        visit followers_user_path(other_user)
      }

      it { should have_title(full_title('Followers')) }
      it { should have_selector('h3', text: 'Followers') }
      it { should have_link(user.name, href: user_path(user)) }
    end
  end
end
