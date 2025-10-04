require 'socket'
require 'fiddle/import'
require 'webrick'

module MediaControl
	extend(Fiddle::Importer)

	dlload('C:\Windows\System32\user32.dll')

	VK_MEDIA_PLAY_PAUSE = 0xB3
	VK_MEDIA_NEXT_TRACK = 0xB0
	VK_MEDIA_PREV_TRACK = 0xB1
	VK_VOLUME_MUTE = 0xAD
	VK_VOLUME_DOWN = 0xAE
	VK_VOLUME_UP = 0xAF
	KEYEVENTF_KEYUP = 2

	typealias 'uchar', 'unsigned char'
	typealias 'ulong', 'unsigned long'

	[
		['void keybd_event(uchar, uchar, int, *ulong)', 'keybd_event']
	].each { |signature, short_name|
		f = extern signature
		define_method short_name, f.to_proc
		module_function short_name
	}
end

HTML_FILE_NAME = File.join __dir__, 'remote.html'

class Responder < WEBrick::HTTPServlet::AbstractServlet

	def initialize _
		@html = File.read(HTML_FILE_NAME)
		# @html_read_at = Time.parse '0000-01-01'
		@html_read_at = File.mtime HTML_FILE_NAME
	end

	def get_html
		if (File.mtime HTML_FILE_NAME) > @html_read_at
			@html = File.read(HTML_FILE_NAME)
		end
		@html
	end

	def do_GET request, response
		response.status = 200
		response.body = get_html
	end

	def do_POST request, response
		# MediaControl.keybd_event(MediaControl::VK_MEDIA_PLAY_PAUSE, 0, MediaControl::KEYEVENTF_KEYUP, nil)
		p request.query
		case request.query['action']
		when 'play_pause'
			MediaControl.keybd_event(MediaControl::VK_MEDIA_PLAY_PAUSE, 0, 0, nil)
		when 'next'
			MediaControl.keybd_event(MediaControl::VK_MEDIA_NEXT_TRACK, 0, 0, nil)
		when 'prev'
			MediaControl.keybd_event(MediaControl::VK_MEDIA_PREV_TRACK, 0, 0, nil)
		when 'vol_up'
			MediaControl.keybd_event(MediaControl::VK_VOLUME_UP, 0, 0, nil)
		when 'vol_mute'
			MediaControl.keybd_event(MediaControl::VK_VOLUME_MUTE, 0, 0, nil)
		when 'vol_down'
			MediaControl.keybd_event(MediaControl::VK_VOLUME_DOWN, 0, 0, nil)
		else
			p 'fignya a ne request'
		end
		response.status = 200
		response.body = get_html
	end
end

our_ip = Socket.ip_address_list.select { |i| i.ipv4_private? }[0].ip_address
qr_file = File.join __dir__, our_ip + '.png'
if not File.exist? qr_file
	require 'rqrcode'
	addr = "http://#{our_ip}:8123"
	qr = RQRCode::QRCode.new addr
	IO.binwrite qr_file, qr.as_png(size: 360).to_s
end
STDERR.puts qr_file

server = WEBrick::HTTPServer.new :Port => 8123
server.mount '/', Responder
trap 'INT' do server.shutdown end
server.start
