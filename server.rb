#By: Bugz
#This is a login web server
#and my first webserver
require 'rubygems'
require 'socket'
require 'pp'
require 'mysql2'
require 'pry'

class Parser
  
  def parse(req, clients)
    
    creds = database
    cred_dump = creds.chomp.delete "\"[[]]\""
    save = File.new("requests.txt", "w+")
    save.write(req.chomp)
    save.close
    words = IO.readlines("requests.txt").last
    if words.delete("\n") == cred_dump
      success(clients)
    else
      response(clients)
    end

    puts words.pretty_inspect
    puts "db dump: " + cred_dump.pretty_inspect
  
  end
end

def database

  dbh = Mysql2::Client.new(
    hostname: 'localhost', 
    username: 'root', 
    password: 'helloworld', 
    database: 'user_pass')  
  value = dbh.query("SELECT pass_v FROM credintials").each(:as => :array).to_s
  dbh.close
  
  return value

end

def success(succ_client)
  
  success_file = File.read("templates/success.html")
  stuff = "HTTP/1.1 200\r\n" + success_file.force_encoding('UTF-8')
  succ_client.puts(stuff)

end

def response(cli)
  
  file = File.read("templates/passpage.html")
  content = "HTTP/1.1 200\r\n" + file.force_encoding('UTF-8')
  cli.puts(content)

end

serv_sock = TCPServer.new('10.0.2.15', 8080)
  
loop {
  client = serv_sock.accept()
  requests = Parser.new
  requests.parse(client.readpartial(2043), client)
  client.close
  
  puts "Connected"
}
