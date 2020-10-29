# frozen_string_literal: true

class SqliteMovieFetcher
  attr_reader :movies_db, :ratings_db, :id, :result, :sql_runner
  attr_accessor :errors

  def initialize(id:, movies_db: nil, ratings_db: nil, sql_runner: nil)
    @movies_db = movies_db || SqliteMoviesConnector.get_connector
    @ratings_db = ratings_db || SqliteRatingsConnector.get_connector
    @id = id
    @errors = []
    @sql_runner = sql_runner || SqliteRunner
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
    sql_runner.execute(
      connector: movies_db,
      sql: get_movie_sql,
      error_receiver: self
    )
  end

  def get_rating
    sql_runner.execute(
      connector: ratings_db,
      sql: get_rating_sql,
      error_receiver: self
    )
  end

  def mapped_movie_keys
    %i[
      movieId
      imdbId
      title
      description
      releaseDate
      budget
      runtime
      genres
      originalLanguage
      productionCompanies
    ]
  end

  def execute
    movie_record = get_movie_record
    return if errors.present?

    movie = mapped_movie_keys.zip(movie_record.pop).to_h
    raw_rating = get_rating
    return if errors.present?

    rating = transform_rating(raw_rating)
    return if errors.present?

    budget = transform_budget(movie[:budget])
    @result = movie.merge(
      { averageRating: rating,
        budget: budget }
    )
  end

  def transform_budget(cents)
    budget = begin
      (cents / 100)
    rescue StandardError
      0
    end
    "$#{budget.to_s(:delimited)}"
  end

  def transform_rating(rating)
    rating.flatten.pop.round(2)
  rescue StandardError => e
    backtrace = e.backtrace.join("\n")
    Rails.logger.error { "#{e.message}\n#{backtrace}" }
    errors << 'Rating missing or non-numeric.'
    false
  end
end
