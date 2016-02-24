require 'httparty'
require 'pry'
require 'audite'
require 'ncurses'
require "highline/import"
require 'open-uri'
require "curses"
require 'stringio'
  new_stderr = StringIO.new
  new_stdout = StringIO.new

    $stderr = new_stderr
    $stdout = new_stdout
include Curses
init_screen

@win = Window.new(10, 100,
                   (lines - 10) / 2, (cols - 100) / 2)
def main params
  system "clear"
  if params[:query] == ""
    show_message("Please add a search term:", 2)
    return
  end
  files = get_list_of_files params
  begin
    chosen_file = files.sample["identifier"]
    show_message("Selected #{chosen_file}",2)
    download_url = get_download_url(files.sample["identifier"])
    show_message("Downloading", 3)
    download_file(params[:file_dir]+chosen_file, download_url)
    show_message("Downloaded",3)
    play_song params[:file_dir]+chosen_file
    ans = ask "More?"
  rescue URI::InvalidURIError => e 
    puts e 
    retry
  end until !params[:autoplay] || ans == "n" 
end

def show_message(message, line)
  @win.box(?|, ?-)
  @win.setpos(line, 3)
  @win.addstr(message)
  @win.refresh
end

def play_song file
  player ||= Audite.new
  length_of_song = 0
  player.events.on(:complete) do
    puts "COMPLETE"
  player.thread.exit
  end

  player.events.on(:position_change) do |pos|
    show_message("PLAYING #{player.current_song_name}",2)
    show_message("#{print_duration(pos, length_of_song)} #{pos.round}\r",3)
  end

  player.load(file)
  length_of_song = player.length_in_seconds.round
  player.start_stream
  player.thread.join
end

def print_duration min, max 
  total_length=80
  filled_amount = "#" * ((min/max)*total_length).round
  empty = " " * (total_length - filled_amount.length)
  end_string = "[#{filled_amount + empty}]"
  return end_string
end

def get_list_of_files params
  url = "https://archive.org/advancedsearch.php?q=#{params[:query]} AND mediatype:audio&fl[]=identifier,title,mediatype&rows=#{params[:rows]}&output=json" 
  response = HTTParty.get(url)
  p_response = response.parsed_response
  return p_response["response"]["docs"]
end

def get_download_url identifier
  url = "https://archive.org/metadata/#{identifier}"
  response = HTTParty.get(url)
  p_response = response.parsed_response
  names = p_response["files"].select { |e| e["name"] =~ /\.mp3$/ }
  #fixes URI error
  return URI.parse(URI.encode("http://archive.org/download/#{identifier}/#{names.sample["name"]}"))
end

def download_file file_dir, url
  open(file_dir, 'wb') do |file|
    file << open(url).read
  end
end


