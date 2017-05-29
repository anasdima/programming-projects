# -- LogTools --
def init_logger logfile
	file = File.open(logfile, File::WRONLY | File::APPEND | File::CREAT)
	logger = Logger.new(file)
	logger.level = Logger::WARN
	logger.datetime_format = '%d-%m-%Y %H:%M:%S'
	logger.formatter = proc do |severity, datetime, progname, msg|
	  	"#{datetime.strftime(logger.datetime_format)} #{msg}\n"
	end
	file.sync = true # Update log on the fly
	return logger
end

# -- EthmmyAgentTools --
def fetch_eTHMMY_subscriptions
	subscriptions = Hash.new {|h,k| h[k] = Array.new}
	File.open($eTHMMY_dropbox_subscriptions_path, 'r') do |f|
		f.each_line do |line|
			line.gsub! /\r\n/, '' # crlf
			if line.match /^\[(.*?)\]$/
				@user = line.delete("[]")
			else
				subscriptions[@user] << line
			end
		end
	end
	return subscriptions
end

# -- ThreadToools --
class DuplicateThread < StandardError; end

def spawn_thread(sym,arg)
	raise DuplicateThread if threads.has_key? sym
	threads[sym] = Thread.new {send sym,arg}
end

def spawn_threads(*symbols)
	symbols.map { |sym| spawn_thread sym }
end

def kill_threads
	threads.values.map(&:kill)
	threads.clear
end

def threads
	@threads ||= {}
end

def spawn_file_watcher file
	spawn_thread(:file_watcher,file)
end

def file_watcher file
	FileWatcher.new(file).watch do |filename,event|
		if(event == :changed)
			@callbacks[:file_change].each {|c| c.call}
		end
	end
end

@callbacks = Hash.new { |h, k| h[k] = [] }
define_method "on_file_change" do |&block|
	@callbacks[:file_change] << block
end