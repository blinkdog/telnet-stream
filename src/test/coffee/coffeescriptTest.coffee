# coffeescriptTest.coffee
# Copyright 2017 Patrick Meade.
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

should = require "should"

describe "CoffeeScript", ->
  it "should iterate through the bytes of an array", ->
    count = {}
    buffer = Buffer.from "Hello"
    for byte in buffer
      count[byte] ?= 0
      count[byte]++
    count["H".charCodeAt(0)].should.equal 1
    count["e".charCodeAt(0)].should.equal 1
    count["l".charCodeAt(0)].should.equal 2
    count["o".charCodeAt(0)].should.equal 1

  it "should allow a default value passthrough assignment", ->
    DEFAULT_ACME = 207
    DEFAULT_WOLVERINE = 9005
    option =
      acme: 5
      batman: 2
      captainCold: 1
    valueAcme = option.acme || DEFAULT_ACME
    valueWolverine = option.wolverine || DEFAULT_WOLVERINE
    valueAcme.should.equal 5
    valueWolverine.should.equal DEFAULT_WOLVERINE

#----------------------------------------------------------------------------
# end of coffeescriptTest.coffee
