require "rails_helper"

RSpec.describe "Post endpoint", type: :request do

  describe 'GET /Posts' do
   

    it "should return OK" do
      get '/posts'
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

    let!(:post){create(:post)}
    
    it "should return a specific post" do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).to eq(post.id)
      expect(payload["title"]).to eq(post.title)
      expect(payload["published"]).to eq(post.published)
      expect(payload["content"]).to eq(post.content)
      expect(payload["author"]["name"]).to eq(post.user.name)
      expect(payload["author"]["email"]).to eq(post.user.email)
      expect(payload["author"]["id"]).to eq(post.user.id)
      expect(response).to have_http_status(200)
    end

  end

  describe "Search" do
    let!(:hola_mundo) { create(:published_post, title: 'Hola Mundo') }
    let!(:hola_rails) { create(:published_post, title: 'Hola Rails') }
    let!(:curso_rails) { create(:published_post, title: 'Curso Rails') }

    it "should filter posts by title" do
      get "/posts?search=Hola"
      payload = JSON.parse(response.body)
      expect(payload).to_not be_empty
      expect(payload.size).to eq(2)
      expect(payload.map { |p| p["id"] }.sort).to eq([hola_mundo.id, hola_rails.id].sort)
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
      expect(payload["error"]).not_to be_empty
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
      expect(payload["error"]).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end
end