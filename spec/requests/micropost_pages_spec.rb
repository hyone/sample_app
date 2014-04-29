require 'spec_helper'
include RequestsHelper


describe "MicropostPages" do

  subject { page }

  let (:user) { FactoryGirl.create(:user) }

  describe "micropost creation" do
    before {
      signin user
      visit root_path
    }

    context 'with invalid info' do
      it 'should not create a micropost' do
        expect { click_button 'Post' }.not_to change(Micropost, :count)
      end

      context 'after submission' do
        before { click_button 'Post' }
        it { should have_message(:error, 'error') }
      end
    end

    context 'with valid info' do
      before {
        fill_in 'micropost_content', with: 'Lorem ipsum'
      }
      it 'should create a micropost' do
        expect { click_button 'Post' }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe 'micropost destruction' do
    before { FactoryGirl.create(:micropost, user: user) }

    context 'with a correct user' do
      before {
        signin user
        visit root_path
      }

      it 'should delete a micropost' do
        expect { click_link 'delete' }.to change(Micropost, :count).by(-1)
      end
    end
  end
end
