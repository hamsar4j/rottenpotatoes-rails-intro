class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if params[:sort_by].present? || params[:ratings].present?
      session[:sort_by] = params[:sort_by]
      session[:ratings] = params[:ratings]
    else
      if session[:sort_by].present? || session[:ratings].present?
        params[:sort_by] = session[:sort_by]
        params[:ratings] = session[:ratings]
        redirect_to movies_path(params) and return
      end
    end

    @movies = if params[:ratings].present?
      Movie.where(rating: params[:ratings].keys)
    else
      Movie.all
    end

    @movies = @movies.order(params[:sort_by]) if params[:sort_by].present?
    @sort_column = params[:sort_by]
    @sort_column_css_class = 'hilite'
    @all_ratings = Movie.all_ratings
    @ratings_to_show_hash = params[:ratings] || {}

    session[:sort_by] = params[:sort_by]
    session[:ratings] = params[:ratings]
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
