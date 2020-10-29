# frozen_string_literal: true

class MovieArrayTransformer
  class << self
    def movie_keys
      %i[imdbId title genres releaseDate budget]
    end

    def execute(results)
      results.map do |row|
        hashed_row = movie_keys.zip(row).to_h
        transform(hashed_row)
      end
    end

    def transform(hashed_row)
      budget = hashed_row[:budget]
      budget = begin
        budget / 100
      rescue StandardError
        0
      end
      hashed_row[:budget] = "$#{budget.to_s(:delimited)}"
      hashed_row
    end
  end
end
