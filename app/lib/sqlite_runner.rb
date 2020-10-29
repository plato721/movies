# frozen_string_literal: true

class SqliteRunner
  def self.execute(connector:, sql:, error_receiver:)
    connector.execute(sql)
  rescue StandardError => e
    backtrace = e.backtrace.join("\n")
    Rails.logger.error { "#{e.message}\n#{backtrace}" }
    error_receiver.errors << 'Retrieval error'
    false
  end
end
