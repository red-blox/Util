local RunService = game:GetService("RunService")

return function(Interval: number, Callback: () -> ())
	local Time = 0
	local DropInterval = Interval * 10

	local Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		Time += DeltaTime

		if Time > DropInterval then
			Time = 0

			Callback()
		elseif Time > Interval then
			Time -= Interval

			Callback()
		end
	end)

	return function()
		Connection:Disconnect()
	end
end
