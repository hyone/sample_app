require 'spec_helper'
include RequestsHelper


describe 'StaticPages' do
  subject { page }

  shared_examples_for 'all static pages' do
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end


  describe 'Home page' do
    let (:heading) { 'Sample App' }
    let (:page_title) { '' }

    context 'with non signin user' do
      before { visit root_path }

      it_should_behave_like 'all static pages'
      it { should_not have_title('| Home') }
    end

    context 'with signin user' do
      let (:user) { FactoryGirl.create(:user) }
      before {
        FactoryGirl.create(:micropost, user: user, content: 'Lorem ipsum')
        FactoryGirl.create(:micropost, user: user, content: 'Dolor sit amet')
        signin user
        visit root_path
      }

      context "in feed" do
        context 'in pagination' do
          before {
            50.times { |i| FactoryGirl.create(:micropost, user: user) }
            visit root_path
          }

          it { should have_selector('div.pagination') }

          it "should render the user's feed in page 1" do
            user.feed.paginate(page: 1).each do |item|
              expect(page).to have_selector("li##{item.id}", text: item.content)
            end
          end

          it 'should not display delete links in microposts of anyone else' do
            user.feed.paginate(page: 1).each do |item|
              unless item.user_id == user.id
                expect(page).not_to have_selector("li#{item.id}", text: item.content)
              end
            end
          end
        end
      end

      context 'in sidebar' do
        context 'about microposts counts' do
          context 'with multiple microposts' do
            it 'should render the correct microposts number' do
              expect(page).to have_content(/#{user.microposts.count} microposts\b/)
            end
          end

          context 'with single micropost' do
            before {
              user.microposts.first.destroy
              visit root_path
            }
            it 'should render 1 micropost' do
              expect(page).to have_content(/1 micropost\b/)
            end
          end

        end

        context 'about follower/following counts' do
          let (:other_user) { FactoryGirl.create(:user) }
          before {
            other_user.follow!(user)
            visit root_path
          }

          it { should have_link('0 following', href: following_user_path(user)) }
          it { should have_link('1 followers', href: followers_user_path(user)) }
        end
      end
    end
  end


  describe 'Help page' do
    before { visit help_path }
    let (:heading) { 'Help' }
    let (:page_title) { 'Help' }

    it_should_behave_like 'all static pages'
  end


  describe 'About page' do
    before { visit about_path }

    let (:heading) { 'About Us' }
    let (:page_title) { 'About' }

    it_should_behave_like 'all static pages'
  end


  describe 'Contact' do
    before { visit contact_path }

    let (:heading) { 'Contact' }
    let (:page_title) { 'Contact' }

    it_should_behave_like 'all static pages'
  end


  describe 'Header' do
    it "have the right links on the layout" do
      visit root_path

      click_link 'About'
      should have_title(full_title('About Us'))

      click_link 'Help'
      should have_title(full_title('Help'))

      click_link 'Contact'
      should have_title(full_title('Contact'))

      click_link 'Home'
      click_link "Sign up now!"
      should have_title(full_title('Sign up'))

      click_link 'sample app'
      should have_title(full_title(''))
    end
  end
end
