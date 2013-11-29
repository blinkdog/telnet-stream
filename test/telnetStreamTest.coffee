# telnetStreamTest.coffee
# Copyright 2013 Patrick Meade. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------------------

should = require 'should'
TelnetStream = require('../lib/telnetStream')

describe 'TelnetStream', ->
  it 'should be OK', ->
    TelnetStream.should.be.ok
    
  it 'should export a reference to TelnetInput', ->
    TelnetStream.TelnetInput.should.be.ok

  it 'should export a reference to TelnetOutput', ->
    TelnetStream.TelnetOutput.should.be.ok

#----------------------------------------------------------------------------
# end of telnetStreamTest.coffee
