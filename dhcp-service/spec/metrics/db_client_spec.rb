require_relative '../spec_helper'
require_relative '../../metrics/db_client'
require 'sequel'

describe DbClient do
    before do
      @db = Sequel.connect(
        adapter: "mysql2",
        host: ENV.fetch("DB_HOST"),
        database: ENV.fetch("DB_NAME"),
        user: ENV.fetch("DB_USER"),
        password: ENV.fetch("DB_PASS")
      )
    end

  describe 'when there are stats in the db' do
    before do
      @db[:lease4_stat].delete

      @db[:lease4_stat].insert(
        subnet_id: 1,
        state: 0,
        leases: 999
      )
      @db[:lease4_stat].insert(
        subnet_id: 2,
        state: 0,
        leases: 333
      )
    end

    it 'returns the lease stats' do
      expected_result = [
        {
          subnet_id: 1,
          state: 0,
          leases: 999
        }, {
          subnet_id: 2,
          state: 0,
          leases: 333
        }
      ]

      expect(subject.get_lease_stats).to eq(expected_result)
    end
  end

  describe 'when there are no stats in the db' do
    before do
      @db[:lease4_stat].delete
    end

    it 'returns an empty list' do
      expected_result = []
      expect(subject.get_lease_stats).to eq(expected_result)
    end
  end
end
