--[[
	COPYRIGHT NOTICE:
	© 2022 Thomas O'Sullivan - All rights reserved.

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

	FILE INFORMATION:
	Name: parser.lua
	Project: gmod-dotenv
	Author: Tom
	Created: 2nd September 2022
--]]

local TEST_BODY = [[#No value on this line, just a comment, the next line doesn't have a value either!

TEST_SINGLE_QUOTES='Single Quotes!'
TEST_DOUBLE_QUOTES="Double Quotes!"
TEST_STRING=Hello World
TEST_STRING_2=Hello World #I hope this comment doesn't cause any problems!
TEST_NUMBER=1.23
TEST_INTEGER=1
TEST_UPPER_BOOLEAN=TRUE
TEST_LOWER_BOOLEAN=FALSE
TEST_MIXED_BOOLEAN=FaLsE #This still works, because why not?
   TEST_VALUE  =    What happens if we space things weirdly for no reason?                               #HELLO
 TEST_VALUE_QUOTED  =    "What happens if we space things weirdly for no reason?"                               #HELLO
TEST_EMPTY= #This should be treated as nil
=-100
 =Broken
    =.19
TEST_HASHTAG_IN_QOUTES="This should not #break"
TEST_WORST_CASE_VALUE="Hello \", how are you # today? I'm good thanks!"
#End of .env...]]

local EXPECTED_PAIRS = {
	["TEST_SINGLE_QUOTES"] = "Single Quotes!",
	["TEST_DOUBLE_QUOTES"] = "Double Quotes!",
	["TEST_STRING"] = "Hello World",
	["TEST_STRING_2"] = "Hello World",
	["TEST_NUMBER"] = "1.23",
	["TEST_INTEGER"] = "1",
	["TEST_UPPER_BOOLEAN"] = "TRUE",
	["TEST_LOWER_BOOLEAN"] = "FALSE",
	["TEST_MIXED_BOOLEAN"] = "FaLsE",
	["TEST_VALUE"] = "What happens if we space things weirdly for no reason?",
	["TEST_VALUE_QUOTED"] = "What happens if we space things weirdly for no reason?",
	["TEST_HASHTAG_IN_QOUTES"] = "This should not #break",
	["TEST_WORST_CASE_VALUE"] = "Hello \\\", how are you # today? I'm good thanks!"
}

local output

return {
	groupName = "Parser",
	beforeAll = function()
		require("dotenv")
	end,
	cases = {
		{
			name = "Parse should error when no body is provided",
			func = function()
				expect(env.parse)
					.to.errWith("Body must be a string.")
			end
		},
		{
			name = "Parse should return a table when a body is provided",
			func = function()
				local success = pcall(function()
					output = env.parse(TEST_BODY)
				end)

				expect(success)
					.to.beTrue()

				expect(output)
					.to.beA("table")
			end
		},
		{
			name = "Empty values should be treated as nil values",
			func = function()
				expect(output["TEST_EMPTY"])
					.to.beNil()
			end
		},
		{
			name = "Only expected keys should be present",
			func = function()
				expect(table.Count(output))
					.to.equal(table.Count(EXPECTED_PAIRS))
			end
		},
		{
			name = "Values should be parsed correctly",
			func = function()
				for key, value in pairs(output) do
					expect(value)
						.to.equal(EXPECTED_VALUES[key])
				end
			end
		}
	}
}