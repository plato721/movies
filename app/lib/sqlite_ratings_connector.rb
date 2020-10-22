class SqliteRatingsConnector
  def self.get_connector
    @@connector ||= SQLite3::Database.new(path)
  end

  def self.path
    ENV.fetch("MOVIES_SQLITE_DB"){ Rails.root.join('./db/ratings.db').to_s }
  end

  def initialize
    raise NoMethodError, "Use .get_connector for the connection"
  end
end
