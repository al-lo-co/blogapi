class PostsController < ApplicationController

  rescue_from Exception do |e|
    render json: {error: e.message}, status: :internal_error
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: {error: e.message}, status: :unprocessable_entity
  end

  before_action :set_post, only: [:show]
  def index
    @posts = Post.where(published: true)
    render json: @posts, status: :ok
  end

  def show
    render json: @post, status: :ok
  end

  def create
    @post = Post.create!(post_params)
    render json: @post, status: :created
  end

  def update
    @post = Post.find(params[:id])
    @post.update!(post_params)
    render json: @post, status: :ok
      
  end
  
  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :published, :user_id)
  end

  def update_params
    params.require(:post).permit(:title, :content, :published)
  end
end