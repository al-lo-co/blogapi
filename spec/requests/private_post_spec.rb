require 'rails_helper'

RSpec.describe "Posts with auth", type: :request do
  let!(:user1){create(:user)}
  let!(:user2){create(:user)}
  let!(:post1){create(:post, user_id: user1.id)}
  let!(:post2){create(:post, user_id: user2.id, published: true)}
  let!(:post3){create(:post, user_id: user2.id, published: false)}
  let!(:auth_headers1){{'Authorization' => "Bearer #{user1.auth_token}"}}
  let!(:auth_headers2){{'Authorization' => "Bearer #{user2.auth_token}"}}

  describe "Get auth posts" do
    context 'Should return ok' do
      context "when requisitin others author post" do
        context "when post is public" do
          before {get "/posts/#{post2.id}", headers: auth_headers1}
          #payload
          context "response" do
            subject { JSON.parse(response.body) } 
            it { is_expected.to include(:id) }
          end
           #response
          context "response" do
            subject { response } 
            it { is_expected.to have_http_status(:ok) }
          end 
        end
        context "when post is draft" do
          before {get "/posts/#{post3.id}", headers: auth_headers1}
          #payload
          context "response" do
            subject { JSON.parse(response.body) } 
            it { is_expected.to include(:error) }
          end
           #response
          context "response" do
            subject { response } 
            it { is_expected.to have_http_status(:not_found) }
          end
          
        end
      end
      context "when requisitin others user post" do
        
      end
    end
  end

  describe "Get auth posts" do
    it 'Should return ok' do
      
    end
  end

  describe "Get auth posts" do
    it 'Should return ok' do
      
    end
  end
end