class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Check if params contain sorting or filtering settings
    if params[:sort_by].present? || params[:ratings].present?
      # Save new sorting and filtering settings in session
      session[:sort_by] = params[:sort_by]
      session[:ratings] = params[:ratings]
    else
      # Check if session contains saved sorting and filtering settings
      if session[:sort_by].present? || session[:ratings].present?
        # Use saved sorting and filtering settings from session
        params[:sort_by] = session[:sort_by]
        params[:ratings] = session[:ratings]
        redirect_to movies_path(params) and return
      end
    end

    # Retrieve movies based on filtering settings
    @movies = if params[:ratings].present?
      Movie.where(rating: params[:ratings].keys)
    else
      Movie.all
    end

    # Apply sorting to movies based on sorting setting
    @movies = @movies.order(params[:sort_by]) if params[:sort_by].present?

    # Set the selected sorting column for highlighting
    @sort_column = params[:sort_by]

    # Set the CSS class for the selected sorting column
    @sort_column_css_class = 'hilite'

    # Get all possible movie ratings for checkboxes
    @all_ratings = Movie.all_ratings

    # Prepare the hash of checked ratings for checkboxes
    @ratings_to_show_hash = params[:ratings] || {}

    # Save the sorting and filtering settings in session
    session[:sort_by] = params[:sort_by]
    session[:ratings] = params[:ratings]
  end

  # def index
  #   if params[:sort_by].present? || params[:ratings].present?
  #     session[:sort_by] = params[:sort_by]
  #     session[:ratings] = params[:ratings]
  #   elsif session[:sort_by].blank? && session[:ratings].blank?
  #     redirect_to movies_path(sort_by: session[:sort_by], ratings: session[:ratings]) and return
  #   end

  #   @movies = Movie.with_ratings(params[:ratings])
  #   @movies = @movies.order(params[:sort_by]) if params[:sort_by].present?
  #   @sort_column = params[:sort_by]
  #   @sort_column_css_class = 'hilite'
  #   @all_ratings = Movie.all_ratings
  #   @ratings_to_show_hash = params[:ratings] || {}

  #   session[:sort_by] = params[:sort_by]
  #   session[:ratings] = params[:ratings]

  #   # @all_ratings = Movie.all_ratings
  #   # @ratings_to_show_hash = params[:ratings] || {}
  #   # @movies = Movie.with_ratings(@ratings_to_show_hash.keys)

  #   # @sort_column = params[:sort_by]
  #   # @sort_column_css_class = nil

  #   # if @sort_column == 'title'
  #   #   @movies = @movies.order(title: :asc)
  #   #   @sort_column_css_class = 'hilite bg-warning'

  #   # elsif @sort_column == 'release_date'
  #   #   @movies = @movies.order(release_date: :asc)
  #   #   @sort_column_css_class = 'hilite bg-warning'
  # end

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
