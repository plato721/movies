class SqliteMovieFetcher
  attr_reader :movies_connector, :ratings_connector, :id, :result
  attr_accessor :errors

  def initialize(id:, movies_connector: nil, ratings_connector: nil)
    @movies_connector = movies_connector || SqliteMoviesConnector.get_connector
    @ratings_connector = ratings_connector || SqliteRatingsConnector.get_connector
    @id = id
    @errors = []
  end

  def get_movie_sql
    <<~SQL
      select movieId, imdbId, title, overview, releaseDate, budget, runtime, genres, language, productionCompanies
      from movies
      where movieId=#{id}
    SQL
  end

  def get_rating_sql
    <<~SQL
      select avg(rating)
      from ratings
      where movieId=#{id}
    SQL
  end

  def get_movie_record
     movies_connector.execute(get_movie_sql)
  rescue StandardError => e
    backtrace = e.backtrace.join("\n")
    Rails.logger.error { "#{e.message}\n#{backtrace}" }
    errors << "Retrieval error"
    false
  end

  def get_rating
    ratings_connector.execute(get_rating_sql)
  end

  def mapped_movie_keys
    %i(
      movieId
      imdbId
      title
      description
      releaseDate
      budget
      runtime
      genres
      originalLanguage
      productionCompanies)
  end

  def execute
     movie_record = get_movie_record
     return if errors.present?

     movie = mapped_movie_keys.zip(movie_record).to_h
     raw_rating = get_rating
     return if errors.present?

     rating = transform_rating(raw_rating)
     return if errors.present?

     rating = { averageRating: rating }
     @result = movie.merge(rating)
  end

  def transform_rating(rating)
    rating.flatten.pop.round(2)
  rescue StandardError => e
    backtrace = e.backtrace.join("\n")
    Rails.logger.error { "#{e.message}\n#{backtrace}" }
    errors << "Rating missing or non-numeric."
    false
  end
end
