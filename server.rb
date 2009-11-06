#!/usr/bin/env ruby
# Created by Hans Sjunnesson (hans.sjunnesson@gmail.com) on 2009-04-25.
# Copyright 2009 Hans Sjunnesson. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
      @s << "<html><body>#{t}</body></html>" << N
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
      puts("Connection from #{session.addr[2]}")
      c.onConnect()
    rescue => e
      STDERR.puts("Error #$!")
    end
  end
end

