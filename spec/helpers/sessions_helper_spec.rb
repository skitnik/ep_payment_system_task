# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  let(:user) { create(:merchant) }
  let(:admin) { create(:admin) }

  before do
    allow(helper).to receive(:session).and_return(session)
  end

  describe '#session_user' do
    context 'when session[:user_id] is present' do
      before { session[:user_id] = user.id }

      it 'returns the user with the corresponding ID' do
        expect(helper.session_user).to eq(user)
      end

      context 'when the user is an admin' do
        before { session[:user_id] = admin.id }

        it 'returns the admin with the corresponding ID' do
          expect(helper.session_user).to eq(admin)
        end
      end
    end

    context 'when session[:user_id] is not present' do
      before { session[:user_id] = nil }

      it 'returns nil' do
        expect(helper.session_user).to be_nil
      end
    end
  end

  describe '#logged_in?' do
    context 'when session_user is present' do
      before { session[:user_id] = user.id }

      it 'returns true' do
        expect(helper.logged_in?).to be(true)
      end
    end

    context 'when session_user is not present' do
      before { session[:user_id] = nil }

      it 'returns false' do
        expect(helper.logged_in?).to be(false)
      end
    end
  end

  describe '#session_user_admin?' do
    context 'when session_user is an active admin' do
      before do
        session[:user_id] = admin.id
        allow(admin).to receive(:active?).and_return(true)
      end

      it 'returns true' do
        expect(helper.session_user_admin?).to be(true)
      end
    end

    context 'when session_user is an inactive admin' do
      before do
        session[:user_id] = admin.id
        allow(helper.session_user).to receive(:active?).and_return(false)
      end

      it 'returns false' do
        expect(helper.session_user_admin?).to be(false)
      end
    end

    context 'when session_user is not an admin' do
      before do
        session[:user_id] = user.id
      end

      it 'returns false' do
        expect(helper.session_user_admin?).to be(false)
      end
    end

    context 'when session_user is nil' do
      before { session[:user_id] = nil }

      it 'returns false' do
        expect(helper.session_user_admin?).to be(false)
      end
    end
  end
end
