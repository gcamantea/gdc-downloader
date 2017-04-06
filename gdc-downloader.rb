# Usage: 
# $ ruby gdc-downloader.rb 'http://evt.dispeak.com/ubm/gdc/sf17/player.html?xml=846277_FNFH.xml&token=26d5b700a93b04d4de020'

require 'net/http'
require 'nokogiri'
require 'uri'
require 'cgi'

player_url = ARGV[0]
uri = URI(player_url)
params = CGI::parse(uri.query)
split = uri.path.split('/')
dir_url = (split.first split.size - 1).join('/')

xml_file_name = params["xml"][0]
xml_base_url = uri.host
xml_path = "#{dir_url}/xml/#{xml_file_name}"

puts "Downloading XML 'http://#{xml_base_url}#{xml_path}'"
xml_content = ''
Net::HTTP.start(xml_base_url) do |http|
  resp = http.get(xml_path)
  xml_content = resp.body
end

xml = Nokogiri::XML(xml_content)
video_path = xml.at_xpath('//MBRVideo[bitrate>1000]/streamName').content.sub("mp4:", "/")

video_base_url = 's3-2u-d.digitallyspeaking.com'
puts "Downloading 'http://#{video_base_url}#{video_path}'"
Net::HTTP.start(video_base_url) do |http|
  resp = http.get(video_path)
  open("video.mp4", "wb") do |file|
    file.write(resp.body)
  end
end
