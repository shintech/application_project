require_relative 'app'
require 'io/console'

app = Scraper.new
app.target = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/"
app.redis_list = "NEWS_XML"
app.config_directory
app.download_files
app.xml_to_redis

puts "All done!!"
puts "Press any key to exit..."
STDIN.getch