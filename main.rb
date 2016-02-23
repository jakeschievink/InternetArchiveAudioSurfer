require 'httparty'
require 'pry'
require 'audite'
require "highline/import"
require 'open-uri'

def main params
  system "clear"
  if params[:query] == ""
    puts "Please add a search term:"
    return
  end
  files = get_list_of_files params
  begin
    chosen_file = files.sample["identifier"]
    puts "Selected #{chosen_file}"
    download_url = get_download_url(files.sample["identifier"])
    puts "Downloading"
    download_file(params[:file_dir]+chosen_file, download_url)
    puts "Downloaded"
    play_song params[:file_dir]+chosen_file
    ans = ask "More?"
  rescue URI::InvalidURIError => e 
    puts e 
    retry
  end until !params[:autoplay] || ans == "n"
end

def play_song file
  player ||= Audite.new
  length_of_song = 0
  player.events.on(:complete) do
    puts "COMPLETE"
  player.thread.exit
  end

  player.events.on(:position_change) do |pos|
    system "clear"
    print "PLAYING #{player.current_song_name}: #{print_duration(pos, length_of_song)} #{pos.round}\r"
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


