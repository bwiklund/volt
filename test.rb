require './volt.rb'

queue = []
queue.push({
  :url => "http://localhost:3000/#!/",
  :path => '/'
})

Volt::Renderer.new({
  :output_dir => 'cache'
},queue)