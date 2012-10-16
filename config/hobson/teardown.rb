puts "WEEEEE"

require 'debugger'
debugger; 1

require 'open3'

# root is the root of the project
Open3.popen3('pwd', :chdir => root.to_s) { |i, o, e, t| p o.read.chomp }

Open3.popen3('bundle exec ruby config/hobson/teardown_with_local_bundle.rb', :chdir => root.to_s) { |i, o, e, t| p o.read.chomp }

#h.rooms_message(room['room_id'], 'tester', "@#{u['mention_name']} sup foo", 1, 'yellow', 'text')