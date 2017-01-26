# EDID hex to dts panel-timing converter
require 'pp'

class Edid
	attr_accessor :pixelclock, 
				:hactive, :vactive, 
				:hblank, :vblank,
				:hsyncoff, :vsyncoff,
				:hsyncpulse, :vsyncpulse,
				:interlaced, :stereo, :sepsync, :hsyncpos, :vsyncpos, :stereomode

	def initialize(filename)
		data=File.read(filename).gsub(/\s+/, "").scan(/../).map{|b| b.to_i(16)}
		desc1=data[54..(54+18-1)]
		pp desc1.map{|b| b.to_s(16)}
		
		@pixelclock=desc1[0] + desc1[1]*256
		@hactive = desc1[2] + (desc1[4] >> 4)*256
		@vactive = desc1[5] + (desc1[7] >> 4)*256
		@hblank = desc1[3] + (desc1[4] & 0xf)*256
		@vblank = desc1[6] + (desc1[7] & 0xf)*256
		@hsyncoff = desc1[8] + (desc1[11] >> 2)*256
		@hsyncpulse = desc1[9] + ((desc1[11] >> 4) & 0b11)*256
		@vsyncoff = (desc1[10] >> 4) + ((desc1[11] >> 6) & 0b11)*256
		@vsyncpulse = (desc1[10] & 0xf) + (desc1[11] & 0b11)*256

		@interlaced = desc1[17] >> 7
		@stereo = (desc1[17] >> 5) & 0b11
		@sepsync = (desc1[17] >> 3) & 0b11
		@hsyncpos = (desc1[17] >> 2) & 0b1
		@vsyncpos = (desc1[17] >> 1) & 0b1
		@stereomode = desc1[17] & 0b1

	end

	def clock_frequency
		@pixelclock * 10000
	end

	def hsync_len 
		@hsyncpulse
	end

	def hfront_porch
		@hsyncoff
	end

	def hback_porch
		@hblank - @hsyncpulse - @hsyncoff
	end

	def vsync_len
		@vsyncpulse
	end

	def vfront_porch
		@vsyncoff
	end

	def vback_porch
		@vblank - @vsyncpulse - @vsyncoff
	end


end

edid=Edid.new("B156XW04_V5.hex")

puts "panel-timing {"
puts " clock-frequency = <#{edid.clock_frequency}>;"
puts " hactive = <#{edid.hactive}>;"
puts " vactive = <#{edid.vactive}>;"

puts " hsync-len = <#{edid.hsync_len}>;"
puts " hfront-porch = <#{edid.hfront_porch}>;"
puts " hback-porch = <#{edid.hback_porch}>;"

puts " vsync-len = <#{edid.vsync_len}>;"
puts " vfront-porch = <#{edid.vfront_porch}>;"
puts " vback-porch = <#{edid.vback_porch}>;"

puts " hsync-active = <#{edid.hsyncpos}>;"
puts " vsync-active = <#{edid.vsyncpos}>;"
puts " pixelclk-active = <0>;"
puts " de-active = <1>;"
puts "};"