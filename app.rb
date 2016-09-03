require "zip"
require 'nokogiri'
require 'open-uri'
require 'redis'
require 'fileutils'

class Scraper
  
  attr_accessor :target, :redis_list

  def initialize
    @r = Redis.new
    @target = target
    @redis_list = redis_list
  end
  
  def xml_to_redis
    urls = []
    page = Nokogiri::HTML(open(@target))
    page.xpath('//a/@href').each do |links|
      urls << links.content
    end
    puts "Downloading files from #{@target}..."
    urls.each do |url|
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
    end
  end
  
end
