require 'httparty'
require 'pry'
require "highline/import"
require 'open-uri'

def main params
  if params[:query] == ""
    puts "Please add a search term:"
    return
  end
  files = get_list_of_files params
  begin
    chosen_file = files.sample["identifier"]
    puts "Selected #{chosen_file}"
    download_url = get_download_url(files.sample["identifier"])
    download_file(params[:file_dir], download_url)
    puts "Downloaded"
    play = `mplayer #{params.file_dir}`
    ans = ask "More?"
  end until !params[:autoplay] || ans == "n"
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
  names = p_response["files"].select { |e| e["name"].include? ".ogg" }
  return "http://archive.org/download/#{identifier}/#{names.sample["name"]}"
end

def download_file file_dir, url
  open(file_dir, 'wb') do |file|
    file << open(url).read
  end
end


