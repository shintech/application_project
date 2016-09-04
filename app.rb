require "zip"
require 'nokogiri'
require 'open-uri'
require 'redis'

class Scraper
  
  attr_accessor :target, :redis_list

  def initialize
    @r = Redis.new
    @target = target
    @redis_list = redis_list
  end
  
  def xml_to_redis
    urls = []
    retries = 3
    page = Nokogiri::HTML(open(@target))
    page.xpath('//a/@href').each do |links|
      urls << links.content
    end
    puts "Downloading files from #{@target}..."
    urls.each do |url|
      begin
        if url.split(".").last == "zip"
          download = open("#{@target}#{url}")
          Zip::File.open(download) do |zip_file|
            zip_file.each do |f|
              xmldoc = f.get_input_stream.read
              @r.sadd "#{@redis_list}", "#{xmldoc}"
            end
            puts "Finished processing #{url}..."
          end
        end
      rescue StandardError => e
        if retries == 0
          puts "Error skipped after three failed attempts..."
          File.write("./log.txt", "Skipped #{@target}#{url} at #{DateTime.now}")
          retries = 3
          next
        else
          puts "Error retrying..."
          retries -= 1
          retry
        end
      ensure
        download.close unless download.nil?
      end
    end
  end
  
end
