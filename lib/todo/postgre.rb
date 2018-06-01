module Database
  def self.connection(ip, port, flag_1, flag_2, db, username, password)
    PG::Connection.new(ip, port, flag_1, flag_2, db, username, password)
  end
end
