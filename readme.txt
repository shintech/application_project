Tested on Xubuntu 15.10
Ruby 2.3.0
Requires Ruby Gems listed below:
  "zip"
  "nokogiri"
  "open-uri"
  "redis"

Downloads files linked to in <a> tags on url specified in app.target and imports contents of zip files to Redis list specified in app.redis_list.

Target url and Redis list can be changed as per instructions below.

Directions:

Open terminal in directory and type "ruby run.rb"

################################################

app.target("http://example.org/whatever")    # url format => "http://example.org/whatever/"
app.redis_list("NEWS_XML")    # name of Redis list.
app.xml_to_redis     # downloads and extracts contents of zip folders to redis_list
