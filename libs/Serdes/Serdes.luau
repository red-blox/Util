local Serdes = {}

function Serdes.Interface(Interface: { string })
	return {
		Ser = function(Value: { [string]: any })
			local Intermediate = {}

			for i, Key in Interface do
				Intermediate[i] = Value[Key]
			end

			return Intermediate
		end,
		Des = function(Intermediate: { any })
			assert(type(Intermediate) == "table", "Expected table for deserialization.")

			local Value = {}

			for i, Key in Interface do
				Value[Key] = Intermediate[i]
			end

			return Value
		end,
	}
end

function Serdes.Enum(Options: { string })
	table.sort(Options)

	local SerMap = {}
	local DesMap = {}

	for i, Option in Options do
		local Char = utf8.char(i)

		SerMap[Option] = Char
		DesMap[Char] = Option
	end

	return {
		Ser = function(Value: string)
			assert(SerMap[Value], "Invalid enum value.")

			return SerMap[Value]
		end,
		Des = function(Intermediate: string)
			assert(DesMap[Intermediate], "Invalid enum value.")

			return DesMap[Intermediate]
		end,
	}
end

Serdes.Number = {
	Ser = function(Value: number)
		local String = tostring(Value)

		if #String < 7 then
			return String :: string | number
		else
			return Value
		end
	end,
	Des = function(Intermediate: string | number)
		assert(
			type(Intermediate) == "string" or type(Intermediate) == "number",
			"Expected string or number for deserialization."
		)

		if type(Intermediate) == "string" then
			return tonumber(Intermediate)
		else
			return Intermediate
		end
	end,
}

Serdes.Integer = {
	Ser = function(Value: number)
		if Value >= 0 and Value < 0x10FFFF then
			return utf8.char(Value) :: string | number
		else
			return Value
		end
	end,
	Des = function(Intermediate: string | number)
		assert(
			type(Intermediate) == "string" or type(Intermediate) == "number",
			"Expected string or number for deserialization."
		)

		if type(Intermediate) == "string" then
			return utf8.codepoint(Intermediate)
		else
			return Intermediate
		end
	end,
}

return Serdes
