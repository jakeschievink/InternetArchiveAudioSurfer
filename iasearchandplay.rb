require 'rubygems'
require 'trollop'
require 'pry'
require 'highline/import'

opts = Trollop::options do
  opt :title, "The title", :type  => :string
end

def main opts
  command = "ia search 'title:#{opts[:title]} mediatype:audio' --itemlist"
  results = `#{command}`
  split_results = results.split("\n")
  puts split_results
  begin 
    downloaded_result = get_download_from split_results
    puts "playing #{downloaded_result}"
    play = `mplayer ./#{downloaded_result}/*.ogg`
  ensure
    FileUtils.remove_dir("./#{downloaded_result}", force = true)
  end until ask "Stop (y/n)" == "n"
end

def get_download_from results
  begin
    chosen_result = results.sample
    download = `ia download #{chosen_result} --glob='*.ogg'`
  end until !download.include? "no matching files found"
  return chosen_result
end

main opts
