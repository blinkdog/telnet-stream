# example0.coffee
# Just an example for README.md
#----------------------------------------------------------------------

# get references to the required stuff
net = require "net"
{TelnetSocket} = require "../telnetStream"

# create a Socket connection
socket = net.createConnection 3000, "godwars2.org"

# decorate the Socket connection as a TelnetSocket
tSocket = new TelnetSocket socket

# if the socket closes, terminate the program
tSocket.on "close", ->
  process.exit()

# if we get any data, display it to stdout
tSocket.on "data", (buffer) ->
  process.stdout.write buffer.toString "utf8"

# if the user types anything, send it to the socket
process.stdin.on "data", (buffer) ->
  tSocket.write buffer.toString "utf8"

#----------------------------------------------------------------------------
# end of example0.coffee
