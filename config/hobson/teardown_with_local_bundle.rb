require 'hipchat-api'

name    = 'Charles Finkel'
hipchat = HipChat::API.new('e90fc81dc47cd1302f8870e94eafa4')
user    = hipchat.users_list['users'].find { |u| u['name'] == name }

bot_room = hipchat.rooms_list['rooms'].find { |r| r['xmpp_jid']== '14943_bot_stuff@conf.hipchat.com' }
hipchat.rooms_message(bot_room['room_id'], 'Hobson', "@#{user['mention_name']} testing", 1, 'yellow', 'text')
