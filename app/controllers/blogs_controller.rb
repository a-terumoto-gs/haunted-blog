# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.not_secret_or_owned(current_user).find(params[:id])
  end

  def new
    @blog = Blog.new
  end

  def edit
    @blog = Blog.owned_by(current_user).find(params[:id])
  end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @blog = Blog.owned_by(current_user).find(params[:id])


    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog = Blog.owned_by(current_user).find(params[:id])

    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    default_permitted_params = [:title, :content, :secret]
    default_permitted_params << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(default_permitted_params)
  end
end
