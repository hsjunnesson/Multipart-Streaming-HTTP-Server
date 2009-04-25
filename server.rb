#!/usr/bin/env ruby

require 'socket'

PORT = ARGV.shift || 8800

N = "\r\n"
HTTP_OK = "HTTP/1.1 200 OK" + N
HTML_TYPE = "Content-type: text/html" + N
BOUND = "BOUND"

class Connection
    def initialize(socket)
        @s = socket
    end
    
    def onConnect
        @s << HTTP_OK
        @s << "Content-type: multipart/x-mixed-replace;boundary=#{BOUND}" << N
        @s << N
        @s << "--#{BOUND}" << N
        
        range = 1..10

        range.each do |count|
            t = Time.now()
            @s << HTML_TYPE
            @s << N
            @s << "<html><body>Count: #{t}</body></html>" << N
            @s << "--#{BOUND}"
            @s << "--" if count == range.last
            @s << N
            @s.flush()

            sleep(1)
        end

        @s.close
    end
end

server = TCPServer.open(PORT)
puts("Server open on #{server.addr[1]}")
trap("PIPE", "IGNORE")

loop do
    session = server.accept
    
    Thread.start do 
        begin
            c = Connection.new(session)
            c.onConnect()
        rescue => e
            puts("Error #$! #{x}")
        end
    end
end

