require "rails_helper"

RSpec.describe "Health endpoint", type: :request do

  describe 'GET /Posts' do
    before{get '/posts'}

    it "should return OK" do
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
    end
  end

  describe 'with data in the db' do

    let!(:posts){create_list(:post, 10, published: true)}

    it "should return all the published posts " do
      get '/posts'
      payload = JSON.parse(response.body)

      expect(payload.size).to eq(posts.size)
      expect(response).to have_http_status(200)
    end
  end
  

  describe 'GET /posts/{id}' do

    let(:post){create(:post)}
    
    it "should return a specific post" do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).to eq(post.id)
      expect(response).to have_http_status(200)
    end

  end

  describe 'Post /posts/' do

    let!(:article){create(:post)}

    it "should create a new post" do
      article_post = {
        post: {
          title: "titulo",
          content: "content",
          published: true,
          user_id: article.user_id
        }
      }

      
      post "/posts", params: article_post

      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).not_to be_nil
      expect(response).to have_http_status(:created)
    end

    it "should return an error message for a new post" do
      article_post = {
        post: {
          title: "titulo",
          content: nil,
          published: true,
          user_id: article.user_id
        }
      }

      post "/posts", params: article_post

      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["error"]).to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end

  describe 'Put /posts/#{id}' do

    let!(:article){create(:post)}
    
    it "should update a post" do
      article_post = {
        post: {
          title: "titulo",
          content: "content",
          published: true
        }
      }

      put "/posts/#{article.id}", params: article_post
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).to eq(article.id)
      expect(response).to have_http_status(:ok)
    end

    it "should return an error message for an update post" do
      article_post = {
        post: {
          title: "titulo",
          content: nil,
          published: true
        }
      }
      
      put "/posts/#{article.id}", params: article_post

      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["error"]).to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end
end