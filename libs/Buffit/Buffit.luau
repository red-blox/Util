--!native
--!nocheck
-- We lie to the type system to provide a better api

type Cursor = {
	Buf: buffer,
	Pos: number,
}

local function Cursor(InitialSize: number): Cursor
	return {
		Buf = buffer.create(InitialSize),
		Pos = 0,
	}
end

local function Grow(Cursor: Cursor)
	local New = buffer.create(buffer.len(Cursor.Buf) * 1.5)
	buffer.copy(New, 0, Cursor.Buf, 0, Cursor.Pos)
	Cursor.Buf = New
end

local function Alloc(Cursor: Cursor, Size: number): number
	local Pos = Cursor.Pos

	while Pos + Size > buffer.len(Cursor.Buf) do
		Grow(Cursor)
	end

	return Pos
end

local function Write(Cursor: Cursor, Size: number): number
	local Pos = Alloc(Size)

	Cursor.Pos = Cursor.Pos + Size

	return Pos
end

local function Read(Cursor: Cursor, Size: number): number
	local Pos = Cursor.Pos

	Cursor.Pos = Cursor.Pos + Size

	return Pos
end

local boolean: boolean = {
	Size = 1,

	Ser = function(Cursor: Cursor, Value: boolean)
		local Pos = Write(Cursor, 1)

		buffer.writeu8(Cursor.Buf, Pos, Value and 1 or 0)
	end,

	Des = function(Cursor: Cursor): boolean
		return buffer.readu8(Cursor.Buf, Read(Cursor, 1)) ~= 0
	end,
}

local u8: number = {
	Size = 1,

	Ser = function(Cursor: Cursor, Value: number)
		local Pos = Write(Cursor, 1)

		buffer.writeu8(Cursor.Buf, Pos, Value)
	end,

	Des = function(Cursor: Cursor): number
		return buffer.readu8(Cursor.Buf, Read(Cursor, 1))
	end,
}

local u16: number = {
	Size = 2,

	Ser = function(Cursor: Cursor, Value: number)
		local Pos = Write(Cursor, 2)

		buffer.writeu16(Cursor.Buf, Pos, Value)
	end,

	Des = function(Cursor: Cursor): number
		return buffer.readu16(Cursor.Buf, Read(Cursor, 2))
	end,
}

local u32: number = {
	Size = 4,

	Ser = function(Cursor: Cursor, Value: number)
		local Pos = Write(Cursor, 4)

		buffer.writeu32(Cursor.Buf, Pos, Value)
	end,

	Des = function(Cursor: Cursor): number
		return buffer.readu32(Cursor.Buf, Read(Cursor, 4))
	end,
}

local i8: number = {
	Size = 1,

	Ser = function(Cursor: Cursor, Value: number)
		local Pos = Write(Cursor, 1)

		buffer.writei8(Cursor.Buf, Pos, Value)
	end,

	Des = function(Cursor: Cursor): number
		return buffer.readi8(Cursor.Buf, Read(Cursor, 1))
	end,
}

local i16: number = {
	Size = 2,

	Ser = function(Cursor: Cursor, Value: number)
		local Pos = Write(Cursor, 2)

		buffer.writei16(Cursor.Buf, Pos, Value)
	end,

	Des = function(Cursor: Cursor): number
		return buffer.readi16(Cursor.Buf, Read(Cursor, 2))
	end,
}

local i32: number = {
	Size = 4,

	Ser = function(Cursor: Cursor, Value: number)
		local Pos = Write(Cursor, 4)

		buffer.writei32(Cursor.Buf, Pos, Value)
	end,

	Des = function(Cursor: Cursor): number
		return buffer.readi32(Cursor.Buf, Read(Cursor, 4))
	end,
}

local f32: number = {
	Size = 4,

	Ser = function(Cursor: Cursor, Value: number)
		local Pos = Write(Cursor, 4)

		buffer.writef32(Cursor.Buf, Pos, Value)
	end,

	Des = function(Cursor: Cursor): number
		return buffer.readf32(Cursor.Buf, Read(Cursor, 4))
	end,
}

local f64: number = {
	Size = 8,

	Ser = function(Cursor: Cursor, Value: number)
		local Pos = Write(Cursor, 8)

		buffer.writef64(Cursor.Buf, Pos, Value)
	end,

	Des = function(Cursor: Cursor): number
		return buffer.readf64(Cursor.Buf, Read(Cursor, 8))
	end,
}

local function string(Size: number?): string
	if Size then
		return {
			Size = Size,

			Ser = function(Cursor: Cursor, Value: string)
				local Pos = Write(Cursor, Size)

				buffer.writestring(Cursor.Buf, Pos, Value, Size)
			end,

			Des = function(Cursor: Cursor): string
				local Pos = Read(Cursor, Size)

				return buffer.readstring(Cursor.Buf, Pos, Size)
			end,
		}
	else
		return {
			Ser = function(Cursor: Cursor, Value: string)
				local Len = #Value
				local Pos = Write(Cursor, Len + 2)

				buffer.writeu16(Cursor.Buf, Pos, Len)
				buffer.writestring(Cursor.Buf, Pos + 2, Value)
			end,

			Des = function(Cursor: Cursor): string
				local Len = buffer.readu16(Cursor.Buf, Read(Cursor, 2))
				local Pos = Read(Cursor, Len)

				return buffer.readstring(Cursor.Buf, Pos, Len)
			end,
		}
	end
end

local function Array<T>(Of: T, Len: number?): { T }
	if Len and Of.Size then
		return {
			Size = Of.Size * Len,

			Ser = function(Cursor: Cursor, Value: { T })
				Alloc(Cursor, Of.Size * Len)

				for Index = 1, Len do
					Of.Ser(Cursor, Value[Index])
				end
			end,

			Des = function(Cursor: Cursor): { T }
				local Result = {}

				for Index = 1, Len do
					Result[Index] = Of.Des(Cursor)
				end

				return Result
			end,
		}
	elseif Of.Size then
		return {
			Ser = function(Cursor: Cursor, Value: { T })
				local Len = #Value
				local Pos = Write(Cursor, 2)
				Alloc(Cursor, Of.Size * Len)

				buffer.writeu16(Cursor.Buf, Pos, Len)

				for Index = 1, Len do
					Of.Ser(Cursor, Value[Index])
				end
			end,

			Des = function(Cursor: Cursor): { T }
				local Len = buffer.readu16(Cursor.Buf, Read(Cursor, 2))
				local Result = table.create(Len)

				for Index = 1, Len do
					Result[Index] = Of.Des(Cursor)
				end

				return Result
			end,
		}
	else
		return {
			Ser = function(Cursor: Cursor, Value: { T })
				local Len = #Value
				local Pos = Write(Cursor, 2)

				buffer.writeu16(Cursor.Buf, Pos, Len)

				for Index = 1, Len do
					Of.Ser(Cursor, Value[Index])
				end
			end,

			Des = function(Cursor: Cursor): { T }
				local Len = buffer.readu16(Cursor.Buf, Read(Cursor, 2))
				local Result = table.create(Len)

				for Index = 1, Len do
					Result[Index] = Of.Des(Cursor)
				end

				return Result
			end,
		}
	end
end

local function Map<K, V>(Key: K, Value: V): { [K]: V }
	return {
		Ser = function(Cursor: Cursor, Value: { [K]: V })
			local LenPos = Write(Cursor, 2)
			local Len = 0

			for i, v in Value do
				Len += 1

				Key.Ser(Cursor, i)
				Value.Ser(Cursor, v)
			end

			buffer.writeu16(Cursor.Buf, LenPos, Len)
		end,

		Des = function(Cursor: Cursor): { [K]: V }
			local Len = buffer.readu16(Cursor.Buf, Read(Cursor, 2))
			local Result = {}

			for _ = 1, Len do
				local Key = Key.Des(Cursor)
				local Value = Value.Des(Cursor)

				Result[Key] = Value
			end

			return Result
		end,
	}
end

local function Struct<T>(Struct: T & { [string]: any }): T
	local FieldList = {}
	local Size = 0

	for Field, Type in Struct do
		if Size and Type.Size then
			Size += Type.Size
		elseif Type.Size == nil then
			Size = nil
		end

		table.insert(FieldList, Field)
	end

	table.sort(FieldList)

	if Size then
		return {
			Size = Size,

			Ser = function(Cursor: Cursor, Value: T)
				Alloc(Cursor, Size)

				for _, Field in FieldList do
					Struct[Field].Ser(Cursor, Value[Field])
				end
			end,

			Des = function(Cursor: Cursor): T
				local Result = table.clone(Struct)

				for _, Field in FieldList do
					Result[Field] = Struct[Field].Des(Cursor)
				end

				return Result
			end,
		}
	else
		return {
			Ser = function(Cursor: Cursor, Value: T)
				for _, Field in FieldList do
					Struct[Field].Ser(Cursor, Value[Field])
				end
			end,

			Des = function(Cursor: Cursor): T
				local Result = table.clone(Struct)

				for _, Field in FieldList do
					Result[Field] = Struct[Field].Des(Cursor)
				end

				return Result
			end,
		}
	end
end

local function Optional<T>(Type: T): T?
	if Type.Size then
		return {
			Size = Type.Size + 1,

			Ser = function(Cursor: Cursor, Value: T?)
				if Value then
					boolean.Ser(Cursor, true)
					Type.Ser(Cursor, Value)
				else
					boolean.Ser(Cursor, false)
				end
			end,

			Des = function(Cursor: Cursor): T?
				if boolean.Des(Cursor) then
					return Type.Des(Cursor)
				else
					return nil
				end
			end,
		}
	else
		return {
			Ser = function(Cursor: Cursor, Value: T?)
				if Value then
					boolean.Ser(Cursor, true)
					Type.Ser(Cursor, Value)
				else
					boolean.Ser(Cursor, false)
				end
			end,

			Des = function(Cursor: Cursor): T?
				if boolean.Des(Cursor) then
					return Type.Des(Cursor)
				else
					return nil
				end
			end,
		}
	end
end

local function Ser<T>(Cursor: Cursor, Type: T, Value: T)
	Type.Ser(Cursor, Value)
end

local function Des<T>(Cursor: Cursor, Type: T): T
	return Type.Des(Cursor)
end

return {
	Cursor = Cursor,
	boolean = boolean,
	u8 = u8,
	u16 = u16,
	u32 = u32,
	i8 = i8,
	i16 = i16,
	i32 = i32,
	f32 = f32,
	f64 = f64,
	string = string,
	Array = Array,
	Map = Map,
	Struct = Struct,
	Optional = Optional,
	Ser = Ser,
	Des = Des,
}
