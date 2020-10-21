class Api::V1::MoviesController < ApplicationController
  def index
    orchestrator = MoviesIndexOrchestrator.new(page: params[:page])
    if orchestrator.execute
      render json: orchestrator.results, status: :ok
    else
      render json: orchestrator.errors, status: :bad_request
    end
  end
end
