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
              raise "error"
              xmldoc = f.get_input_stream.read
              @r.sadd "#{@redis_list}", "#{xmldoc}"
            end
            puts "Finished processing #{url}..."
            download.close
          end
        end
      rescue => error
        if retries == 0
          puts "Error skipped after three failed attempts..."
          report_error("#{error.class} and #{error.message} at #{DateTime.now}\n##Skipped #{@target}#{url} at #{DateTime.now}")
          log_errors
          retries = 3
          next
        else
          puts "Error retrying..."
          retries -= 1
          retry
        end
      end
    end
  end

  def report_error(error_message)
    (Thread.current[:errors] ||= []) << "#{error_message}"
  end

  def log_errors
      File.open('log.txt', 'a') do |file|
      (Thread.current[:errors] ||= []).each do |error|
        file.puts error
      end
    end
  end

end
