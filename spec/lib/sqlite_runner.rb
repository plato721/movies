# frozen_string_literal: true

require 'rails_helper'

class FakeRunnerClient
  attr_reader :errors

  def initialize
    @errors = []
  end
end

describe SqliteRunner do
  let(:sql) do
    <<~SQL
      select * from users;
    SQL
  end
  let(:connector) do
    double(:connector)
  end
  let(:client) do
    double(:client, errors: [])
  end

  it 'executes some sql against a connector' do
    allow(connector).to receive(:execute)
    described_class.execute(
      error_receiver: client,
      connector: connector,
      sql: sql
    )

    expect(connector).to have_received(:execute).with(sql)
  end

  it 'records errors in the client' do
    allow(connector).to receive(:execute) {
                          raise StandardError, 'Something bad happened.'
                        }

    result = described_class.execute(
      error_receiver: client,
      connector: connector,
      sql: sql
    )
    expect(result).to be_falsey
    expect(client.errors).to be_present
  end
end
