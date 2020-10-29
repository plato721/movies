# frozen_string_literal: true

# sqlite> .schema movies
# CREATE TABLE movies (
#   movieId INTEGER PRIMARY KEY,
#   imdbId TEXT NOT NULL,
#   title TEXT NOT NULL,
#   overview TEXT,
#   productionCompanies TEXT,
#   releaseDate TEXT,
#   budget INTEGER,
#   revenue INTEGER,
#   runtime REAL,
#   language TEXT,
#   genres TEXT,
#   status TEXT);
class SqliteMoviesConnector
  def self.get_connector
    @@connector ||= SQLite3::Database.new(path)
  end

  def self.path
    ENV.fetch('MOVIES_SQLITE_DB') { Rails.root.join('./db/movies.db').to_s }
  end

  def initialize
    raise NoMethodError, 'Use .get_connector for the connection'
  end
end
