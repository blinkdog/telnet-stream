# example2-client.coffee
# Just an example for README.md
#----------------------------------------------------------------------

# Negotiate About Window Size -- See RFC 1073
NAWS = 31

# get references to the required stuff
net = require "net"
{TelnetSocket} = require "../telnetStream"

# create a Socket connection
socket = net.createConnection 3000
# decorate the Socket connection as a TelnetSocket
tSocket = new TelnetSocket socket

# flag to indicate if its OK to send window size subnegotiations to the server
serverNawsOk = false

# function: send window size to the server
sendWindowSize = ->
  # create a buffer
  nawsBuffer = Buffer.alloc 4
  # fill the buffer up with our window dimensions
  nawsBuffer.writeInt16BE process.stdout.columns, 0
  nawsBuffer.writeInt16BE process.stdout.rows, 2
  # send that buffer as a subnegotiation to the server
  tSocket.writeSub NAWS, nawsBuffer

# if the socket closes, terminate the program
tSocket.on "close", ->
  process.exit()

# if we get any data, display it to stdout
tSocket.on "data", (buffer) ->
  process.stdout.write buffer.toString "utf8"

# if the server sends us a DO negotiation
tSocket.on "do", (option) ->
  # if that negotiation is about window size
  if option is NAWS
    # set the flag indicating that the server has
    # told us it's OK to send our window size
    serverNawsOk = true
    # tell the server that we WILL send window size
    tSocket.writeWill NAWS
    # send our current window size to the server
    sendWindowSize()

# if the user types anything, send it to the socket
process.stdin.on "data", (buffer) ->
  tSocket.write buffer.toString "utf8"

# if the terminal window is resized
process.stdout.on "resize", ->
  # if we're OK to send our window size to the server
  if serverNawsOk
    # send the new window size to the server
    sendWindowSize()

#----------------------------------------------------------------------------
# end of example2-server.coffee
