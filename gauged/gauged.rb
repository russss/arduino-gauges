require "serialport.so"
require "socket"

class ArduinoPWM

	def initialize()
		@sp = SerialPort.open("/dev/ttyUSB0", 9600, 8, 1, SerialPort::NONE);
	end	

	def setPort(port, val)
		@sp.write(port.chr)
		@sp.write(val.chr)
		@sp.write("\n")
	end
	
	def close()
		@sp.close
	end
end

class GaugeController<ArduinoPWM
	def initialize()
		super
		@gauges = Hash.new
	end
	
	def initGauge(port, minScale, maxScale, minPWM, maxPWM)
		@gauges[port] = Hash.new
		@gauges[port][:minScale] = minScale
		@gauges[port][:maxScale] = maxScale
		@gauges[port][:minPWM] = minPWM
		@gauges[port][:maxPWM] = maxPWM
		@gauges[port][:cur] = 0
	end

	def setGauge(port, val)
		data = @gauges[port]
		if val > data[:maxScale]
			val = data[:maxScale]
		end
		
		if val < data[:minScale]
			val = data[:minScale]
		end
		val = val.to_f / (data[:maxScale] - data[:minScale]) * (data[:maxPWM] - data[:minPWM])
        p "Setting port " + port.to_s + " to val " + val.to_i.to_s
		setPort(port, val.to_i)
		@gauges[port][:cur] = val
	end
end

pwm = GaugeController.new()


pwm.initGauge(11, 0, 1000, 0, 225)
pwm.initGauge(5, 0, 1000, 0, 218)
pwm.initGauge(9, 0, 350, 0, 255)
pwm.initGauge(6, 0, 350, 0, 227)
pwm.initGauge(3, 0, 90,  0, 255)

while true
	d = Hash.new
	begin
		t = TCPSocket.new('admintools.last.fm', '51835')
		t.each {|line|
			parts = line.split(":")
			if parts
				d[parts[0].to_sym] = parts[1]
			end
		}	
		t.close
	rescue	
		puts $!
	end
	p d
	pwm.setGauge(9, d[:time].to_f * 100)
	pwm.setGauge(6, d[:size].to_i)
	pwm.setGauge(3, d[:queuetime].to_f * 10)
    pwm.setGauge(5, d[:globalload].to_f / 10)
    pwm.setGauge(11, d[:catslaveload].to_f / 10)
	sleep 5
end

pwm.close()
