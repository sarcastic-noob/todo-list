# frozen_string_literal: true

require 'spec_helper'
require 'todo'
require 'rack/test'

RSpec.describe Database do
  context 'check connection status'
  it 'is connected to database' do
    expect(Database.connection('127.0.0.1', 5432, nil, nil, 'postgres', 'postgres', 'ggwp').status).to eq(0)
  end

  context 'check connection status with wrong password'
  it 'raises error if wrong password is passed in Postgre Connection' do
    expect { Database.connection('127.0.0.1', 5432, nil, nil, 'postgres', 'postgres', 'ntut') }
      .to raise_error(PG::ConnectionBad)
  end

  context 'check connection status with wrong port'
  it 'raises error for wrong port input in Postgre Connection' do
    expect { Database.connection('127.0.0.1', 5462, nil, nil, 'postgres', 'postgres', 'ggwp') }
      .to raise_error(PG::ConnectionBad)
  end
end
