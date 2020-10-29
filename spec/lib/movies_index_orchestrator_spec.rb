# frozen_string_literal: true

require 'rails_helper'

describe MoviesIndexOrchestrator do
  context 'validations' do
    it 'changes a nil page to page 1' do
      orchestrator = described_class.new(page: nil)

      expect(orchestrator).to be_valid
      expect(orchestrator.page).to eql('1')
    end

    it 'adds errors for non-integer (as string) page' do
      orchestrator = described_class.new(page: '8.4')

      expect(orchestrator).to_not be_valid
      expect(orchestrator.errors).to_not be_empty
    end
  end

  context 'limit/offset computation'
end
