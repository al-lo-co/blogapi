class PostsController < ApplicationController
  include Secured
  before_action :set_post, only: [:show]
  before_action :auth_user!, only: [:update, :create]


  rescue_from Exception do |e|
    render json: {error: e.message}, status: :internal_error
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: {error: e.message}, status: :not_found
  end
  
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: {error: e.message}, status: :unprocessable_entity
  end

  def index
    @posts = Post.where(published: true)
    if !params[:search].nil? && params[:search].present?
      
      @posts = @posts.where("title like '%#{params[:search]}%'")
    end
    render json: @posts.includes(:user), status: :ok
  end

  def show
    
    if(@post.published? || (Current.user && @post.user_id == Current.user.id))
      render json: @post, status: :ok
    else
      render json: {error: 'Not Found'}, status: :not_found
    end
  end

  def create
    @post = Current.user.posts.create!(post_params)
    render json: @post, status: :created
  end

  def update
    @post = Current.user.posts.find(params[:id])
    @post.update!(post_params)
    render json: @post, status: :ok
  end
  
  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :published)
  end

  def update_params
    params.require(:post).permit(:title, :content, :published)
  end
end