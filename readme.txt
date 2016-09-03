Tested on Xubuntu 15.10
Ruby 2.3.0
Requires Ruby Gems listed below:
  "zip"
  "nokogiri"
  "open-uri"
  "redis"
  "fileutils"

Downloads files linked to in <a> tags on url specified in Scraper.target to .bin/download_directory.
Extracts zip files from .bin/download_directory to .bin/data_directory
Imports contents of xml files in .bin/data_directory to Redis list entitled 'NEWS_XML'.

Target url and Redis list can be changed as per instructions below.

Directions:

Open terminal in directory and type "ruby run.rb"

################################################

app.target("http://example")    # url format => "http://example.org/whatever/"
app.redis_list("NEWS_XML")    # name of Redis list.
app.create_folders    # creates data and download directories in bin folder.
app.download_files    # downloads the files to bin/folder.download.
app.extract_zip_files     # extracts zip files to bin/folder.data.
app.to_redis    # uploads contents of files in bin/folder.data to Redis list.
