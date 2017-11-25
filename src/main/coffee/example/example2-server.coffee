# example2-server.coffee
# Just an example for README.md
#----------------------------------------------------------------------

# Negotiate About Window Size -- See RFC 1073
NAWS = 31

# get references to the required stuff
net = require "net"
{TelnetSocket} = require "../telnetStream"

# create a service to listen for incoming connections
server = net.createServer (socket) ->
  # wrap the socket as a TelnetSocket
  tSocket = new TelnetSocket socket

  # if we get any data, display it to the console
  tSocket.on "data", (buffer) ->
    process.stdout.write buffer.toString "utf8"

  # if they send us a subnegotiation
  tSocket.on "sub", (option, buffer) ->
    # if they are telling us their window size
    if option is NAWS
      # display it to the console
      width = buffer.readInt16BE 0
      height = buffer.readInt16BE 2
      process.stdout.write "Client window: #{width}x#{height}\n"

  # tell the client to send window size subnegotiations
  tSocket.writeDo NAWS

# start our server listening on port 3000
server.listen 3000

#----------------------------------------------------------------------------
# end of example2-server.coffee
