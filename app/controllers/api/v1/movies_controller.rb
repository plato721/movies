class Api::V1::MoviesController < ApplicationController
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
      error = orchestrator.errors.first

      render json: { error: error.message }, status: error.status
    end
  end
end
