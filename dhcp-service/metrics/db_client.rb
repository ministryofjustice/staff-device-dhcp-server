class DbClient
  def initialize
    @db = Sequel.connect(
      adapter: "mysql2",
      host: ENV.fetch("DB_HOST"),
      database: ENV.fetch("DB_NAME"),
      user: ENV.fetch("DB_USER"),
      password: ENV.fetch("DB_PASS")
    )
  end

  def get_lease_stats
    db[:lease4_stat].all
  end

  attr_reader :db
end
