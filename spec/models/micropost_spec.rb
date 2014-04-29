require 'spec_helper'


describe Micropost do
  let (:user) { FactoryGirl.create(:user) }

  before {
    @micropost = user.microposts.build(content: 'Lorem ipsum')
  }

  subject { @micropost }


  it "original micropost should be valid" do
    should be_valid
  end


  describe 'content' do
    it { should respond_to(:content) }

    context 'with blank content' do
      before { @micropost.content = '  ' }
      it { should_not be_valid }
    end

    context 'with content that is too long' do
      before { @micropost.content = 'a' * 141 }
      it { should_not be_valid }
    end
  end

  describe 'user_id' do
    it { should respond_to(:user_id) }

    context 'when not present' do
      before { @micropost.user_id = nil }
      it { should_not be_valid }
    end
  end

  describe 'user' do
    it { should respond_to(:user) };
    # belongs_to
    its(:user) { should eq user }
  end
end
