require 'rails_helper'

RSpec.describe "Posts with auth", type: :request do
  let!(:user_a){create(:user)}
  let!(:user_b){create(:user)}
  let!(:post_a){create(:post, user_id: user_a.id)}
  let!(:post_b){create(:post, user_id: user_b.id, published: true)}
  let!(:post_c){create(:post, user_id: user_b.id, published: false)}
  let!(:auth_headers_a){{'Authorization' => "Bearer #{user_a.auth_token}"}}
  let!(:auth_headers_b){{'Authorization' => "Bearer #{user_b.auth_token}"}}
  let!(:create_params){ {"post" => {"title" => "title",  "content" => "content", "published" => true }} }
  let!(:update_params){ {"post" => {"title" => "title",  "content" => "content", "published" => true }} }


  describe "Get auth posts" do
    context 'Should return ok' do
      context "when requisiting others author post" do
        context "when post is public" do
          before { get "/posts/#{post_b.id}", headers: auth_headers_a}
          #payload
          context "response" do
            subject { payload } 
            it { is_expected.to include(:id) }
          end
           #response
          context "response" do
            subject { response } 
            it { is_expected.to have_http_status(:ok) }
          end 
        end
        context "when post is draft" do
          before {get "/posts/#{post_c.id}", headers: auth_headers_a}
          #payload
          context "response" do
            subject { payload } 
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

  describe "Get auth posts created" do
    context 'With valid auth' do
      before {post "/posts", params: create_params, headers: auth_headers_a}
        #payload
        context "response" do
          subject { payload } 
          it { is_expected.to include(:id, :content, :published, :author) }
        end
          #response
        context "response" do
          subject { response } 
          it { is_expected.to have_http_status(:created) }
        end
      end
      context 'Without valid auth' do
        before {post "/posts", params: create_params}
        #payload
        context "response" do
          subject { payload } 
          it { is_expected.to include(:error) }
        end
          #response
        context "response" do
          subject { response } 
          it { is_expected.to have_http_status(:unauthorized) }
        end
      end
  end

  describe "Get auth posts update" do
    context 'With valid auth' do
      before {put "/posts/#{post_a.id}", params: update_params, headers: auth_headers_a}
        #payload
      context "payload" do
        subject { payload } 
        it { is_expected.to include(:id, :content, :published, :author) }
        it { expect(payload[:id]).to eq(post_a.id) }
      end
        #response
      context "response" do
        subject { response } 
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context 'With valid auth other user post' do
      before {put "/posts/#{post_b.id}", params: update_params, headers: auth_headers_a}
        #payload
      context "payload" do
        subject { payload } 
        it { is_expected.to include(:error) }
      end
        #response
      context "response" do
        subject { response } 
        it { is_expected.to have_http_status(:not_found) }
      end
    end

    
    
  end

  private
  def payload
    JSON.parse(response.body).with_indifferent_access
  end
end