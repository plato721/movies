# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Movies', type: :request do
  describe 'index' do
    it 'gets the movies' do
      get '/api/v1/movies', params: { page: 1 }

      expect(response).to have_http_status(:ok)

      movies = json_body['movies']
      expect(movies.count).to eq(50)

      movie = movies[0]
      expected_keys = %w[imdbId title genres releaseDate budget]
      expect(movie.keys).to match_array(expected_keys)
      expect(movie['budget']).to match(/^\$(\d{1,3},)*(\d{1,3})*$/)
    end

    it 'fails on a bad page' do
      get '/api/v1/movies', params: { page: 'not a number' }

      expect(response).to have_http_status(400)
    end
  end

  describe 'show' do
    it 'gets a movie' do
      # TODO: - this will fail if this id/movie change
      get '/api/v1/movies/1089'

      expect(response).to have_http_status(:ok)
      movie = json_body['movie']
      expected_keys = %w[
        movieId
        imdbId
        title
        description
        releaseDate
        budget
        runtime
        averageRating
        genres
        originalLanguage
        productionCompanies
      ]
      expect(movie.keys).to match_array(expected_keys)
      expect(movie['budget']).to eq('$240,000')
    end
  end
end
