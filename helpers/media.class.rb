require 'fileutils'

module MediaHelpers

	def upload_file(file, destination)
		serial = 'mdbk_' + Time.now.to_i
		extension ||= (/(.jpg|.png|.jpeg|.webp|.mp4|.mp3|.mov|.wav|.doc|.pdf")$/).match(file)
		return false if extension.nil?
		sleep 1
		FileUtils.copy(file[:tempfile].path, "/#{serial}" + extension)
	end
end