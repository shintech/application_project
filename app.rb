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
  
  def config_directory
    folder = "#{DateTime.now.strftime('%Y-%m-%d')}-" + "#{@target}".split('/').last
    @download = "bin/#{folder}_download"
    FileUtils.mkdir_p @download
  end
  
  def download_files
    retries = 3
    urls = []
    page = Nokogiri::HTML(open(@target))
    page.xpath('//a/@href').each do |links|
      urls << links.content
    end
    puts "Downloading files from #{@target}..."
    urls.each do |url|
      if url.split(".").last == "zip" && !File.file?(url)
        begin
          Timeout.timeout(60) do 
            download = open("#{@target}#{url}")
            IO.copy_stream(download, "#{@download}/#{url}")
            puts "Downloaded #{url}..."
          end
        rescue Timeout::Error
          if retries > 0
            puts "Timeout, retrying..."
            retries -= 1
            `echo "Timeout error" >> log.txt`
            retry
          else
            puts "Connection error, aborting..."
            `echo "Connection aborted" >> log.txt`
            exit
          end
        end
      end
    end
  end
  
  def xml_to_redis
    FileUtils.mkdir_p @data
    dir = Dir["#{@download}/*.zip"]
    puts "\nPlease wait..."
    puts "Extracting zip files from #{@download}..."
    dir.each do |d|
      Zip::File.open(d) do |zip_file|
        zip_file.each do |f|
          xmldoc = f.get_input_stream.read
          @r.sadd "#{@redis_list}", "#{xmldoc}"
        end
      end
    end
  end
  
end
