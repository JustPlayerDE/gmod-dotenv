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
=-100
 =Broken

#End of .env...]]

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
			name = "Quotes should be stripped from values if a matching pair is found",
			func = function()
				expect(output["TEST_SINGLE_QUOTES"])
					.to.beEqual("Single Quotes!")

				expect(output["TEST_DOUBLE_QUOTES"])
					.to.beEqual("Double Quotes!")
			end
		},
		{
			name = "Whitespace should be trimmed from keys and values",
			func = function()
				expect(output["TEST_VALUE"])
					.to.beEqual("What happens if we space things weirdly for no reason?")

				expect(output["TEST_VALUE_QUOTED"])
					.to.beEqual("What happens if we space things weirdly for no reason?")
			end
		},
		{
			name = "Comments should stripped from values",
			func = function()
				expect(output["TEST_STRING_2"])
					.to.beEqual("Hello World")
			end
		},
		{
			name = "Empty lines should be ignored",
			func = function()
				expect(output[""])
					.to.beNil()

				expect(output[" "])
					.to.beNil()

				expect(output["\n"])
					.to.beNil()
			end
		}
	}
}