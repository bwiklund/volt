#!/usr/bin/env ruby

require 'open-uri'

module Volt
  class Renderer
    def initialize(options,queue)
      @options = options
      @queue = queue
      start_worker_threads
    end


    def start_worker_threads
      @job_counter = 0
      @start_time = Time.now

      num_threads = 8
      threads = []
      num_threads.times do |thread_num|
        threads << create_worker_thread(thread_num)
      end
      threads.each {|t| t.join}

      puts "All threads done"
    end


    def create_worker_thread(thread_num)
      Thread.new(thread_num) { |thread_num|
        while job = @queue.shift

          job_num = @job_counter+=1

          puts "#{job_num} | Thread ##{thread_num} Starting " + job[:url] + " ..."
          take_snapshot job[:url], job[:path]
          puts "#{job_num} | Thread ##{thread_num} Finished " + job[:url]

          elapsed = (Time.now - @start_time)
          puts elapsed.to_s + " elapsed"

        end
      }
    end


    def take_snapshot(url,save_as)
      html = `phantomjs snapshot.coffee #{url}`
      filename = URI::escape save_as, '/'
      File.open( @options[:output_dir] + '/' + filename, 'w' ){|f| f.write(html)}
    end

  end

end