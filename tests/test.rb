require_relative '../lib/volt.rb'

queue = [{
  :url => "http://localhost:3000/#!/",
  :path => '/'
}]

options = {
  :output_dir => 'cache'
}

Volt::Renderer.new(queue,queue)