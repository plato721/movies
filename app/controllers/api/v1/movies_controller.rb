# frozen_string_literal: true

module Api
  module V1
    class MoviesController < ApplicationController
      def index
        orchestrator = MoviesIndexOrchestrator.new(page: params[:page])

        if orchestrator.execute
          render json: orchestrator.results, status: :ok
        else
          render json: orchestrator.errors, status: :bad_request
        end
      end

      def show
        orchestrator = MoviesShowOrchestrator.new(id: params[:id])

        if orchestrator.execute
          render json: orchestrator.result, status: :ok
        else
          render json: orchestrator.errors, status: :bad_request
        end
      end
    end
  end
end
