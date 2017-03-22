bot = dofile('/home/username/inline/data/utils.lua')
json = dofile('/home/username/inline/data/JSON.lua')
URL = require "socket.url"
serpent = require("serpent")
http = require "socket.http"
https = require "ssl.https"
redis = require('redis')
db = redis.connect('127.0.0.1', 6379)
BASE = '/home/username/inline/bot/'
SUDO = 304107094 --sudo id
sudo_users = {304107094,123456789,Userid}
BOTS = 00000000 --bot id
bot_id = db:get(SUDO..'bot_id')
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function dl_cb(arg, data)
 -- vardump(data)
  --vardump(arg)
end

  function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
    if msg.sender_user_id_ == v then
      var = true
    end
  end
  return var
end
------------------------------------------------------------
function is_master(msg) 
  local hash = db:sismember(SUDO..'masters:'..msg.sender_user_id_)
if hash or is_sudo(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_bot(msg)
  if tonumber(BOTS) == 313139061 then
    return true
    else
    return false
    end
  end
  ------------------------------------------------------------
function is_owner(msg) 
  local hash = db:sismember(SUDO..'owners:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_mod(msg) 
  local hash = db:sismember(SUDO..'mods:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) or is_owner(msg) then
return true
else
return false
end
end
------------------------------------------------------------
function is_banned(chat,user)
   local hash =  db:sismember(SUDO..'banned'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
  ------------------------------------------------------------
  function is_filter(msg, value)
  local hash = db:smembers(SUDO..'filters:'..msg.chat_id_)
  if hash then
    local names = db:smembers(SUDO..'filters:'..msg.chat_id_)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_mod(msg) then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
  end
  ------------------------------------------------------------
function is_muted(chat,user)
   local hash =  db:sismember(SUDO..'mutes'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
  	-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
-----------------------------------------------------------------------------------------------
function priv(chat,user)
  local ohash = db:sismember(SUDO..'owners:'..chat,user)
  local mhash = db:sismember(SUDO..'mods:'..chat,user)
 if tonumber(SUDO) == tonumber(user) or mhash or ohash then
   return true
    else
    return false
    end
  end
  ------------------------------------------------------------
function kick(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید دیگر مدیران را اخراج کنید!</code>', 'html')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
    end
  end
  ------------------------------------------------------------
function ban(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید دیگر مدیران را از گروه مسدود کنید!</code>', 'html')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
  db:sadd(SUDO..'banned'..chat,user)
  local t = '<code>>کاربر</code> [<b>'..user..'</b>] <code>از گروه مسدود گردید.</code>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t, 1, 'html')
  end
  end
  ------------------------------------------------------------
function mute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شما نمیتوانید توانایی گفتگو در گروه را از دیگر مدیران سلب کنید!</code>', 'html')
    else
  db:sadd(SUDO..'mutes'..chat,user)
  local t = '<code>>کاربر</code> [<b>'..user..'</b>] <code>به حالت سکوت کاربران افزوده گردید.</code>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  end
  ------------------------------------------------------------
function unban(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem(SUDO..'banned'..chat,user)
  local t = '<code>>کاربر</code> [<b>'..user..'</b>] <code>از لیست کاربران مسدود شده خارج گردید.</code>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  ------------------------------------------------------------
function unmute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem(SUDO..'mutes'..chat,user)
  local t = '<code>>کاربر</code> [<b>'..user..'</b>]  <code>از حالت سکوت کاربران حذف گردید.</code>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  ------------------------------------------------------------
 function delete_msg(chatid,mid)
  tdcli_function ({ID="DeleteMessages", chat_id_=chatid, message_ids_=mid}, dl_cb, nil)
end
------------------------------------------------------------
function user(msg,chat,text,user)
  entities = {}
  if text:match('<user>') and text:match('<user>') then
      local x = string.len(text:match('(.*)<user>'))
      local offset = x
      local y = string.len(text:match('<user>(.*)</user>'))
      local length = y
      text = text:gsub('<user>','')
      text = text:gsub('</user>','')
   table.insert(entities,{ID="MessageEntityMentionName", offset_=offset, length_=length, user_id_=user})
  end
    entities[0] = {ID='MessageEntityBold', offset_=0, length_=0}
return tdcli_function ({ID="SendMessage", chat_id_=chat, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_=entities}}, dl_cb, nil)
end
------------------------------------------------------------
function settings(msg,value,lock) 
local hash = SUDO..'settings:'..msg.chat_id_..':'..value
  if value == 'file' then
      text = 'فیلتر-فایل'
   elseif value == 'keyboard' then
    text = 'فیلتر-درون.خطی(کیبرد شیشه ای)'
  elseif value == 'link' then
    text = 'قفل-ارسال لینک'
  elseif value == 'game' then
    text = 'انجام بازی های(انلاین)'
    elseif value == 'username' then
    text = 'ارسال یوزرنیم(@)'
   elseif value == 'pin' then
    text = 'قفل پین-کردن(پیام)'
    elseif value == 'photo' then
    text = 'فیلتر-تصاویر'
    elseif value == 'gif' then
    text = 'فیلتر-تصاویر-متحرک'
    elseif value == 'video' then
    text = 'فیلتر-ویدئو'
    elseif value == 'audio' then
    text = 'فیلتر-صدا(audio-voice)'
    elseif value == 'music' then
    text = 'فیلتر-آهنگ(MP3)'
    elseif value == 'text' then
    text = 'فیلتر-متن'
    elseif value == 'sticker' then
    text = 'ارسال-برچسب'
    elseif value == 'contact' then
    text = 'فیلتر-مخاطبین'
    elseif value == 'forward' then
    text = 'فیلتر-فوروارد'
    elseif value == 'persian' then
    text = 'فیلتر-گفتمان(فارسی)'
    elseif value == 'english' then
    text = 'فیلتر-گفتمان(انگلیسی)'
    elseif value == 'bot' then
    text = 'قفل ورود-ربات(API)'
    elseif value == 'tgservice' then
    text = 'فیلتر-پیغام-ورود،خروج افراد'
    else return false
    end
  if lock then
db:set(hash,true)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>*</b> <code>'..text..'</code> >  فعال شد.',1,'html')
    else
  db:del(hash)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>*</b> <code>'..text..'</code> >  غیرفعال شد.',1,'html')
end
end
------------------------------------------------------------
function is_lock(msg,value)
local hash = SUDO..'settings:'..msg.chat_id_..':'..value
 if db:get(hash) then
    return true 
    else
    return false
    end
  end
------------------------------------------------------------
function trigger_anti_spam(msg,type)
  if type == 'kick' then
    kick(msg,msg.chat_id_,msg.sender_user_id_)
    end
  if type == 'ban' then
    if is_banned(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..msg.sender_user_id_..'</b>] <code>به دلیل ارسال پیام مکرر(بیش از حد مجاز) از گروه مسدود گردید و ارتباط آن با گروه قطع گردید.</code>', 1,'md')
      end
bot.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
  db:sadd(SUDO..'banned'..msg.chat_id_,msg.sender_user_id_)
  end
	if type == 'mute' then
    if is_muted(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..msg.sender_user_id_..'</b>] <code>به دلیل ارسال پیام مکرر(بیش از حد مجاز) به حالت سکوت منتقل شد</code>\n<code>برای خارج شدن از لیست سکوت کاربران به مدیریت مراجعه کنید</code>', 1,'md')
      end
  db:sadd(SUDO..'mutes'..msg.chat_id_,msg.sender_user_id_)
	end
  end
function televardump(msg,value)
  local text = json:encode(value)
  bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 'html')
  end
------------------------------------------------------------
function run(msg,data)
   --vardump(data)
  --televardump(msg,data)

    if msg then
            db:incr(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
      if msg.send_state_.ID == "MessageIsSuccessfullySent" then
      return false 
      end
      end
    if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end
    local text = msg.content_.text_
	if text and text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
		text = text
		end
    --------- messages type -------------------
    if msg.content_.ID == "MessageText" then
      msg_type = 'text'
    end
    if msg.content_.ID == "MessageChatAddMembers" then
      msg_type = 'add'
    end
    if msg.content_.ID == "MessageChatJoinByLink" then
      msg_type = 'join'
    end
    if msg.content_.ID == "MessagePhoto" then
      msg_type = 'photo'
      end
    -------------------------------------------
    if msg_type == 'text' and text then
      if text:match('^[/!]') then
      text = text:gsub('^[/!]','')
      end
    end
  
     if text then
      if not db:get(SUDO..'bot_id') then
         function cb(a,b,c)
         db:set(SUDO..'bot_id',b.id_)
         end
      bot.getMe(cb)
      end
    end
  ------------------------------------------------------------
    if chat_type == 'super' then
    NUM_MSG_MAX = 5
    if db:get(SUDO..'floodmax'..msg.chat_id_) then
      NUM_MSG_MAX = db:get(SUDO..'floodmax'..msg.chat_id_)
      end
      TIME_CHECK = 3
    if db:get(SUDO..'floodtime'..msg.chat_id_) then
      TIME_CHECK = db:get(SUDO..'floodtime'..msg.chat_id_)
      end
    if text and text:match('test (%d+)') then
     
      end
    -- check flood
    if db:get(SUDO..'settings:flood'..msg.chat_id_) then
    if not is_mod(msg) then
      local post_count = 'user:' .. msg.sender_user_id_ .. ':floodc'
      local msgs = tonumber(db:get(post_count) or 0)
      if msgs > tonumber(NUM_MSG_MAX) and not msg.content_.ID == "MessageChatAddMembers" then
       local type = db:get(SUDO..'settings:flood'..msg.chat_id_)
        trigger_anti_spam(msg,type)
      end
      db:setex(post_count, tonumber(TIME_CHECK), msgs+1)
    end
    end
-- save pin message id
  if msg.content_.ID == 'MessagePinMessage' then
 if is_lock(msg,'pin') and is_owner(msg) then
 db:set(SUDO..'pinned'..msg.chat_id_, msg.content_.message_id_)
  elseif not is_lock(msg,'pin') then
 db:set(SUDO..'pinned'..msg.chat_id_, msg.content_.message_id_)
 end
 end
 -- check filters
    if text and not is_mod(msg) then
     if is_filter(msg,text) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end 
    end
-- check settings
    
     -- lock tgservice
      if is_lock(msg,'tgservice') then
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" or msg.content_.ID == "MessageChatDeleteMember" then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
    -- lock pin
    if is_owner(msg) then else
      if is_lock(msg,'pin') then
        if msg.content_.ID == 'MessagePinMessage' then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>قفل پیغام پین شده فعال است</code>\n<code>شما دارای مقام نمیباشید و امکان پین کردن پیامی را ندارید</code>',1, 'html')
      bot.unpinChannelMessage(msg.chat_id_)
          local PinnedMessage = db:get(SUDO..'pinned'..msg.chat_id_)
          if PinnedMessage then
             bot.pinChannelMessage(msg.chat_id_, tonumber(PinnedMessage), 0)
            end
          end
        end
      end
      if is_mod(msg) then
        else
        -- lock link
        if is_lock(msg,'link') then
          if text then
        if msg.content_.entities_ and msg.content_.entities_[0] and msg.content_.entities_[0].ID == 'MessageEntityUrl' or msg.content_.text_.web_page_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or text:match("[Jj][Oo][Ii][Nn][Cc][Hh][Aa][Tt]/") or text:match("[Tt].[Mm][Ee]/")
            if is_link then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock username
        if is_lock(msg,'username') then
          if text then
       local is_username = text:match("@[%a%d]")
        if is_username then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_username = text:match("@[%a%d]")
            if is_username then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock sticker 
        if is_lock(msg,'sticker') then
          if msg.content_.ID == 'MessageSticker' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
end
          end
        -- lock forward
        if is_lock(msg,'forward') then
          if msg.forward_info_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
          end
        -- lock photo
        if is_lock(msg,'photo') then
          if msg.content_.ID == 'MessagePhoto' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock file
        if is_lock(msg,'file') then
          if msg.content_.ID == 'MessageDocument' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
      -- lock file
        if is_lock(msg,'keyboard') then
          if msg.reply_markup_ and msg.reply_markup_.ID == 'ReplyMarkupInlineKeyboard' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
      -- lock game
        if is_lock(msg,'game') then
          if msg.content_.game_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock music 
        if is_lock(msg,'music') then
          if msg.content_.ID == 'MessageAudio' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock voice 
        if is_lock(msg,'audio') then
          if msg.content_.ID == 'MessageVoice' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock gif
        if is_lock(msg,'gif') then
          if msg.content_.ID == 'MessageAnimation' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end 
        -- lock contact
        if is_lock(msg,'contact') then
          if msg.content_.ID == 'MessageContact' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock video 
        if is_lock(msg,'video') then
          if msg.content_.ID == 'MessageVideo' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
           end
          end
        -- lock text 
        if is_lock(msg,'text') then
          if msg.content_.ID == 'MessageText' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock persian 
        if is_lock(msg,'persian') then
          if text:match('[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_persian = text:match("[ضصثقفغعهخحجچپشسیبلاتنمکگظطزرذدئو]")
            if is_persian then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock english 
        if is_lock(msg,'english') then
          if text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_english = text:match("[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]")
            if is_english then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock bot
        if is_lock(msg,'bot') then
       if msg.content_.ID == "MessageChatAddMembers" then
            if msg.content_.members_[0].type_.ID == 'UserTypeBot' then
        kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
              end
            end
          end
      end

-- check mutes
      local muteall = db:get(SUDO..'muteall'..msg.chat_id_)
      if msg.sender_user_id_ and muteall and not is_mod(msg) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
      if msg.sender_user_id_ and is_muted(msg.chat_id_,msg.sender_user_id_) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
-- check bans
    if msg.sender_user_id_ and is_banned(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>کاربر مورد نظر مسدود نمیباشد!</code>',1, 'html')
      end
-- welcome
    local status_welcome = (db:get(SUDO..'status:welcome:'..msg.chat_id_) or 'disable') 
    if status_welcome == 'enable' then
			    if msg.content_.ID == "MessageChatJoinByLink" then
        if not is_banned(msg.chat_id_,msg.sender_user_id_) then
     function wlc(extra,result,success)
        if db:get(SUDO..'welcome:'..msg.chat_id_) then
        t = db:get(SUDO..'welcome:'..msg.chat_id_)
        else
        t = 'سلام {name}\nخوش آمدید!'
        end
      local t = t:gsub('{name}',result.first_name_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
          end
        bot.getUser(msg.sender_user_id_,wlc)
      end
        end
        if msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].type_.ID == 'UserTypeGeneral' then

    if msg.content_.ID == "MessageChatAddMembers" then
      if not is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      if db:get(SUDO..'welcome:'..msg.chat_id_) then
        t = db:get(SUDO..'welcome:'..msg.chat_id_)
        else
        t = 'سلام {name}\nخوش آمدید!'
        end
      local t = t:gsub('{name}',msg.content_.members_[0].first_name_)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
      end
        end
          end
      end
      -- locks
    if text and is_owner(msg) then
      local lock = text:match('^lock pin$')
       local unlock = text:match('^unlock pin$')
      if lock then
          settings(msg,'pin','lock')
          end
        if unlock then
          settings(msg,'pin')
        end
      end 
    if text and is_mod(msg) then
       local lock = text:match('^lock (.*)$')
       local unlock = text:match('^unlock (.*)$')
      local pin = text:match('^lock pin$') or text:match('^unlock pin$')
      if pin and is_owner(msg) then
        elseif pin and not is_owner(msg) then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>انجام این دستور برای شما مجاز نمیباشد!</code>',1, 'html')
        elseif lock then
          settings(msg,lock,'lock')
        elseif unlock then
          settings(msg,unlock)
        end
        end
    
 -- lock flood settings
    if text and is_owner(msg) then
       local hash = SUDO..'settings:flood'..msg.chat_id_
      if text == 'lock flood kick' then
      db:set(hash,'kick') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>قفل ارسال پیام مکرر فعال گردید!</code> \n<code>وضعیت</code> > <i>اخراج(کاربر)</i>',1, 'html')
      elseif text == 'lock flood ban' then
        db:set(hash,'ban') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>قفل ارسال پیام مکرر فعال گردید!</code> \n<code>وضعیت</code> > <i>مسدود-سازی(کاربر)</i>',1, 'html')
        elseif text == 'lock flood mute' then
        db:set(hash,'mute') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>قفل ارسال پیام مکرر فعال گردید!</code> \n<code>وضعیت</code> > <i>سکوت(کاربر)</i>',1, 'html')
        elseif text == 'unlock flood' then
        db:del(hash) 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, ' <code>قفل ارسال پیام مکرر غیرفعال گردید!</code> ',1, 'html')
            end
          end
       
        -- sudo
    if text then
      if is_sudo(msg) then
        if text == 'leave' then
            bot.changeChatMemberStatus(msg.chat_id_, bot_id, "Left")
          end
        if text == 'ownerset' then
          function prom_reply(extra, result, success)
        db:sadd(SUDO..'owners:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به لیست مالکین گروه افزوده گردید.</code>', 1, 'html')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^ownerset (%d+)') then
          local user = text:match('ownerset (%d+)')
          db:sadd(SUDO..'owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به لیست مالکین گروه افزوده گردید.</code>', 1, 'html')
      end
        if text == 'ownerdem' then
        function prom_reply(extra, result, success)
        db:srem(SUDO..'owners:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..result.sender_user_id_..'</b>] <code>از لیست مالکین گروه حذف گردید و توانایی مدیریت گروه از کاربر گفته شد.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text and text:match('^ownerdem (%d+)') then
          local user = text:match('ownerdem (%d+)')
         db:srem(SUDO..'owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>از لیست مالکین گروه حذف گردید و توانایی مدیریت گروه از کاربر گفته شد.</code>', 1, 'html')
      end
        end
      if text == 'delete owners' or text == 'delete ownerlist' then
        db:del(SUDO..'owners:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>به لیست ادمین های ربات افزوده گردید.</code>', 1, 'html')
        end
      --------------------------master--------------------------
	   if text == 'masterset' then
          function prom_reply(extra, result, success)
        db:sadd(SUDO..'masters:'..result.sender_user_id_)
        local master = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..master..'</b>] <code>به لیست ادمین های ربات افزوده گردید.</code>', 1, 'html')
        end
        if tonumber(tonumber(msg.reply_to_message_id_)) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^masterset (%d+)') then
          local master = text:match('masterset (%d+)')
          db:sadd(SUDO..'masters:'..master)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..master..'</b>] <code>به لیست ادمین های ربات افزوده گردید.</code>', 1, 'html')
      end
        if text == 'masterdem' then
        function prom_reply(extra, result, success)
        db:srem(SUDO..'masters:'..result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..result.sender_user_id_..'</b>] <code>از لیست ادمین های ربات حذف گردید.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        if text and text:match('^masterdem (%d+)') then
          local master = text:match('masterdem (%d+)')
         db:srem(SUDO..'masters:'..master)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..master..'</b>] <code>از لیست ادمین های ربات حذف گردید.</code>', 1, 'html')
      end
        end
	  ---############################################--
	   if text == 'reload' and is_sudo(msg) then
       dofile('bot.lua') 
 bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>تغییرات مورد نظر شما اعمال شد.</code>', 1, 'html')
            end
	    if text == 'statsbot' and is_sudo(msg) then
    local gps = db:scard("botgp")
	local users = db:scard("usersbot")
    local allmgs = db:get("allmsg")

					bot.sendMessage(msg.chat_id_, msg.id_, 1, '>آمار ربات:\n\n`> سوپرگروه ها:` [*'..gps..'*]\n`> کاربران:` [*'..users..'*]\n`> کل پیام های دریافتی:` [*'..allmgs..'*]', 1, 'md')
	end
	  --###########################################--
      -- owner
     if is_owner(msg) then
        if text == 'delete bots' then
      local function cb(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          kick(msg,msg.chat_id_,bots[i].user_id_)
          end
        end
       bot.channel_get_bots(msg.chat_id_,cb)
       end
          if text and text:match('^setlink (.*)') then
            local link = text:match('setlink (.*)')
            db:set(SUDO..'grouplink'..msg.chat_id_, link)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لینک جدید با موفقیت ذخیره و تغییر یافت.</code>', 1, 'html')
            end
          if text == 'remlink' then
            db:del(SUDO..'grouplink'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لینک تنظیم شده با موفقیت بازنشانی گردید.</code>', 1, 'html')
            end
            if text and text:match('^setname (.*)') then
            local name = text:match('^setname (.*)')
            bot.changeChatTitle(msg.chat_id_, name)
            end
        if text == 'welcome enable' then
          db:set(SUDO..'status:welcome:'..msg.chat_id_,'enable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>ارسال پیام خوش آمدگویی فعال گردید.</code>', 1, 'html')
          end
        if text == 'welcome disable' then
          db:set(SUDO..'status:welcome:'..msg.chat_id_,'disable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>ارسال پیام خوش آمدگویی غیرفعال گردید.</code>', 1, 'html')
          end
        if text and text:match('^setwelcome (.*)') then
          local welcome = text:match('^setwelcome (.*)')
          db:set(SUDO..'welcome:'..msg.chat_id_,welcome)
          local t = '<code>>پیغام خوش آمدگویی با موفقیت ذخیره و تغییر یافت.</code>\n<code>>متن پیام خوش آمدگویی تنظیم شده:</code>:\n{<code>'..welcome..'</code>}'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
        if text == 'delete welcome' then
          db:del(SUDO..'welcome:'..msg.chat_id_,welcome)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>پیغام خوش آمدگویی بازنشانی گردید و به حالت پیشفرض تنظیم شد.</code>', 1, 'html')
          end
        if text == 'owners' or text == 'ownerlist' then
          local list = db:smembers(SUDO..'owners:'..msg.chat_id_)
          local t = '<code>>لیست مالکین گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\nبرای مشاهده کاربر از دستور زیر استفاده کنید \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 234458457</code>'
          if #list == 0 then
          t = '<code>>لیست مالکان گروه خالی میباشد!</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    if text == 'modset' then
        function prom_reply(extra, result, success)
        db:sadd(SUDO..'mods:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^modset @(.*)') then
        local username = text:match('^modset @(.*)')
        function promreply(extra,result,success)
          if result.id_ then
        db:sadd(SUDO..'mods:'..msg.chat_id_,result.id_)
        text ='<code>>کاربر</code> [<code>'..result.id_..'</code>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>' 
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,promreply)
        end
        if text and text:match('^modset (%d+)') then
          local user = text:match('modset (%d+)')
          db:sadd(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
      end
        if text == 'moddem' then
        function prom_reply(extra, result, success)
        db:srem(SUDO..'mods:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..result.sender_user_id_..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^moddem @(.*)') then
        local username = text:match('^moddem @(.*)')
        function demreply(extra,result,success)
          if result.id_ then
        db:srem(SUDO..'mods:'..msg.chat_id_,result.id_)
        text = '<code>>کاربر</code> [<b>'..result.id_..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>'
            else 
            text = '<code>کاربر مورد نظر یافت نشد</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,demreply)
        end
        if text and text:match('^modset (%d+)') then
          local user = text:match('modset (%d+)')
          db:sadd(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>به مقام مدیریت گروه ارتقاء یافت.</code>', 1, 'html')
      end
        if text and text:match('^moddem (%d+)') then
          local user = text:match('moddem (%d+)')
         db:srem(SUDO..'mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>کاربر</code> [<b>'..user..'</b>] <code>از مقام مدیریت گروه عزل گردید.</code>', 1, 'html')
      end
  end
      end
-- mods
    if is_mod(msg) then
      local function getsettings(value)
        if value == 'muteall' then
        local hash = db:get(SUDO..'muteall'..msg.chat_id_)
        if hash then
         return '<code>فعال</code>'
          else
          return '<code>غیرفعال</code>'
          end
        elseif value == 'welcome' then
        local hash = db:get(SUDO..'welcome:'..msg.chat_id_)
        if hash == 'enable' then
         return '<code>فعال</code>'
          else
          return '<code>غیرفعال</code>'
          end
        elseif value == 'spam' then
        local hash = db:get(SUDO..'settings:flood'..msg.chat_id_)
        if hash then
             if db:get(SUDO..'settings:flood'..msg.chat_id_) == 'kick' then
         return '<code>User-kick</code>'
              elseif db:get(SUDO..'settings:flood'..msg.chat_id_) == 'ban' then
              return '<code>User-ban</code>'
							elseif db:get(SUDO..'settings:flood'..msg.chat_id_) == 'mute' then
              return '<code>Mute</code>'
              end
          else
          return '<code>مجاز</code>'
          end
        elseif is_lock(msg,value) then
          return '<code>غیرمجاز</code>'
          else
          return '<code>مجاز</code>'
          end
        end
        ---------------------------------------------------
      if text == 'settings' then
          function inline(arg,data)
          tdcli_function({
        ID = "SendInlineQueryResultMessage",
        chat_id_ = msg.chat_id_,
        reply_to_message_id_ = msg.id_,
        disable_notification_ = 0,
        from_background_ = 1,
        query_id_ = data.inline_query_id_,
        result_id_ = data.results_[0].id_
      }, dl_cb, nil)
            end
          tdcli_function({
      ID = "GetInlineQueryResults",
      bot_user_id_ = 254778917,
      chat_id_ = msg.chat_id_,
      user_location_ = {
        ID = "Location",
        latitude_ = 0,
        longitude_ = 0
      },
      query_ = tostring(msg.chat_id_),
      offset_ = 0
    }, inline, nil)
       end
	   --[[if text == 'muteslist' then
        local text = '><b>Group-Filterlist:</b>\n<b>----------------</b>\n'
        ..'><code>Filter-Photo:</code> |'..getsettings('photo')..'|\n'
        ..'><code>Filter-Video:</code> |'..getsettings('video')..'|\n'
        ..'><code>Filter-Audio:</code> |'..getsettings('voice')..'|\n'
        ..'><code>Filter-Gifs:</code> |'..getsettings('gif')..'|\n'
        ..'><code>Filter-Music:</code> |'..getsettings('music')..'|\n'
        ..'><code>Filter-File:</code> |'..getsettings('file')..'|\n'
        ..'><code>Filter-Text:</code> |'..getsettings('text')..'|\n'
        ..'><code>Filter-Contacts:</code> |'..getsettings('contact')..'|\n'
        ..'><code>Filter-Forward:</code> |'..getsettings('forward')..'|\n'
        ..'><code>Filter(Inline-mod):</code> |'..getsettings('game')..'|\n'
        ..'><code>Filter-Service(Join):</code> |'..getsettings('tgservice')..'|\n'
        ..'><code>Mute-Chat:</code> |'..getsettings('muteall')..'|\n'
        bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, '')
       end]]
      if text and text:match('^floodmax (%d+)$') then
          db:set(SUDO..'floodmax'..msg.chat_id_,text:match('floodmax (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>حداکثر پیام تشخیص ارسال پیام مکرر تنظیم شد به:</code> [<b>'..text:match('floodmax (.*)')..'</b>] <code>تغییر یافت.</code>', 1, 'html')
        end
        if text and text:match('^floodtime (%d+)$') then
          db:set(SUDO..'floodtime'..msg.chat_id_,text:match('floodtime (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>حداکثر زمان تشخیص ارسال پیام مکرر تنظیم شد به:</code> [<b>'..text:match('floodtime (.*)')..'</b>] <code>ثانیه.</code>', 1, 'html')
        end
        if text == 'link' then
          local link = db:get(SUDO..'grouplink'..msg.chat_id_) 
          if link then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>لینک گروه به گروه:</code> \n'..link, 1, 'html')
            else
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>لینک ورود به گروه تنظیم نشده است.</code>\n<code>ثبت لینک جدید با دستور</code>\n<b>/setlink</b> <i>link</i>\n<code>امکان پذیر است.</code>', 1, 'html')
            end
          end
        if text == 'mutechat' then
          db:set(SUDO..'muteall'..msg.chat_id_,true)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>فیلتر تمامی گفتگو ها فعال گردید!</code>', 1, 'html')
          end
        if text and text:match('^mutechat (%d+)[mhs]') or text and text:match('^mutechat (%d+) [mhs]') then
          local matches = text:match('^mutechat (.*)')
          if matches:match('(%d+)h') then
          time_match = matches:match('(%d+)h')
          time = time_match * 3600
          end
          if matches:match('(%d+)s') then
          time_match = matches:match('(%d+)s')
          time = time_match
          end
          if matches:match('(%d+)m') then
          time_match = matches:match('(%d+)m')
          time = time_match * 60
          end
          local hash = SUDO..'muteall'..msg.chat_id_
          db:setex(hash, tonumber(time), true)
          bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>>فیلتر تمامی گفتگو ها برای مدت زمان</code> [<b>'..time..'</b>] <code>ثانیه فعال گردید.</code>', 1, 'html')
          end
        if text == 'unmutechat' then
          db:del(SUDO..'muteall'..msg.chat_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>فیلتر تمامی گفتگو ها غیرفعال گردید!</code>', 1, 'html')
          end
        if text == 'mutechat status' then
          local status = db:ttl(SUDO..'muteall'..msg.chat_id_)
          if tonumber(status) < 0 then
            t = 'زمانی برای آزاد شدن چت تعییین نشده است !'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
            else
          t = '[<b>'..status..'</b>] <code>ثانیه دیگر تا غیرفعال شدن فیلتر تمامی گفتگو ها باقی مانده است.</code>'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
          end
    if text == 'bans' or text == 'banlist' then
          local list = db:smembers(SUDO..'banned'..msg.chat_id_)
          local t = '<code>>لیست افراد مسدود شده از گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code>\n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>لیست افراد مسدود شده از گروه خالی میباشد.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == 'delete bans' or text == 'delete banlist' then
        db:del(SUDO..'banned'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لیست کاربران مسدود شده از گروه با موفقیت بازنشانی گردید.</code>', 1, 'html')
        end
        if text == 'mutes' or text == 'silentlist' then
          local list = db:smembers(SUDO..'mutes'..msg.chat_id_)
          local t = '<code>لیست کاربران حالت سکوت</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = 'لیست افراد میوت شده خالی است !'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end      
      if text == 'delete mutesss' or text == 'delete silentlist' then
        db:del(SUDO..'mutes'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لیست افراد کاربران لیست سکوت با موفقیت حذف گردید..</code>', 1, 'html')
        end
      if text == 'kick' and tonumber(msg.reply_to_message_id_) > 0 then
        function kick_by_reply(extra, result, success)
        kick(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),kick_by_reply)
        end
      if text and text:match('^kick (%d+)') then
        kick(msg,msg.chat_id_,text:match('kick (%d+)'))
        end
      if text and text:match('^kick @(.*)') then
        local username = text:match('kick @(.*)')
        function kick_username(extra,result,success)
          if result.id_ then
            kick(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,kick_username)
        end
        if text == 'ban' and tonumber(msg.reply_to_message_id_) > 0 then
        function banreply(extra, result, success)
        ban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
      if text and text:match('^ban (%d+)') then
        ban(msg,msg.chat_id_,text:match('ban (%d+)'))
        end
      if text and text:match('^ban @(.*)') then
        local username = text:match('ban @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            ban(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,banusername)
        end
      if text == 'unban' and tonumber(msg.reply_to_message_id_) > 0 then
        function unbanreply(extra, result, success)
        unban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end
      if text and text:match('^unban (%d+)') then
        unban(msg,msg.chat_id_,text:match('unban (%d+)'))
        end
      if text and text:match('^unban @(.*)') then
        local username = text:match('unban @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unban(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unbanusername)
        end
        if text == 'silentuser' and tonumber(msg.reply_to_message_id_) > 0 then
        function mutereply(extra, result, success)
        mute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),mutereply)
        end
      if text and text:match('^silentuser (%d+)') then
        mute(msg,msg.chat_id_,text:match('silentuser (%d+)'))
        end
      if text and text:match('^silentuser @(.*)') then
        local username = text:match('silentuser @(.*)')
        function muteusername(extra,result,success)
          if result.id_ then
            mute(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,muteusername)
        end
      if text == 'unsilentuser' and tonumber(msg.reply_to_message_id_) > 0 then
        function unmutereply(extra, result, success)
        unmute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unmutereply)
        end
      if text and text:match('^unsilentuser (%d+)') then
        unmute(msg,msg.chat_id_,text:match('unsilentuser (%d+)'))
        end
      if text and text:match('^unsilentuser @(.*)') then
        local username = text:match('unsilentuser @(.*)')
        function unmuteusername(extra,result,success)
          if result.id_ then
            unmute(msg,msg.chat_id_,result.id_)
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unmuteusername)
        end
         if text == 'invite' and tonumber(msg.reply_to_message_id_) > 0 then
        function inv_by_reply(extra, result, success)
        bot.addChatMembers(msg.chat_id_,{[0] = result.sender_user_id_})
        end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),inv_by_reply)
        end
      if text and text:match('^invite (%d+)') then
        bot.addChatMembers(msg.chat_id_,{[0] = text:match('invite (%d+)')})
        end
      if text and text:match('^invite @(.*)') then
        local username = text:match('invite @(.*)')
        function invite_username(extra,result,success)
          if result.id_ then
        bot.addChatMembers(msg.chat_id_,{[0] = result.id_})
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,invite_username)
        end
      if text and text:match('^del (%d+)$') then
        local limit = tonumber(text:match('^del (%d+)$'))
        if limit > 100 then
         bot.sendMessage(msg.chat_id_, msg.id_, 1, 'تعداد پیام وارد شده از حد مجاز (100 پیام) بیشتر است !', 1, 'html')
          else
         function cb(a,b,c)
        local msgs = b.messages_
        for i=1 , #msgs do
          delete_msg(msg.chat_id_,{[0] = b.messages_[i].id_})
        end
        end
        bot.getChatHistory(msg.chat_id_, 0, 0, limit + 1,cb)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, limit..' پیام اخیر گروه پاک شد !', 1, 'html')
        end
        end
      if tonumber(msg.reply_to_message_id_) > 0 then
    if text == "del" then
        delete_msg(msg.chat_id_,{[0] = tonumber(msg.reply_to_message_id_),msg.id_})
    end
        end
	
    if text == 'managers' or text == 'mods' then
          local list = db:smembers(SUDO..'mods:'..msg.chat_id_)
          local t = '<code>>لیست مدیران گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>'
          if #list == 0 then
          t = '<code>>مدیریت برای این گروه ثبت نشده است.</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == 'delete mods' or text == 'delete managers' then
        db:del(SUDO..'mods:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>لیست مدیران گروه با موفقیت بازنشانی شد</code>', 1, 'html')
        end
      if text and text:match('^filter +(.*)') then
        local w = text:match('^filter +(.*)')
         db:sadd(SUDO..'filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'" '..w..' "  <code>>به لیست کلمات فیلتر شده اضاف گردید!</code>', 1, 'html')
       end
      if text and text:match('^unfilter +(.*)') then
        local w = text:match('^unfilter +(.*)')
         db:srem(SUDO..'filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'" '..w..' "  <code>>از لیست کلمات فیلتر شده پاک شد!</code>', 1, 'html')
       end
      if text == 'delete filterlist' then
        db:del(SUDO..'filters:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<code>>تمامی کلمات فیلتر شده با موفقیت حذف گردیدند.</code>', 1, 'html')
        end
      if text == 'admins' or text == 'adminlist' then
        local function cb(extra,result,success)
        local list = result.members_
           local t = '<code>>لیست ادمین های گروه:</code>\n\n'
          local n = 0
            for k,v in pairs(list) do
           n = (n + 1)
              t = t..n.." - "..v.user_id_.."\n"
                    end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t..'\n<code>>برای مشاهده کاربر از دستور زیر استفاده کنید </code> \n<code>/whois [آیدی کاربر]</code>\n مثال :\n <code>/whois 159887854</code>', 1, 'html')
          end
       bot.channel_get_admins(msg.chat_id_,cb)
      end
      if text == 'filterlist' then
          local list = db:smembers(SUDO..'filters:'..msg.chat_id_)
          local t = '<code>>لیست کلمات فیلتر شده در گروه:</code> \n\n'
          for k,v in pairs(list) do
          t = t..k.." - "..v.."\n" 
          end
          if #list == 0 then
          t = '<code>>لیست کلمات فیلتر شده خالی میباشد</code>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    local msgs = db:get(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
    if msg_type == 'text' then
        if text then
      if text:match('^whois @(.*)') then
        local username = text:match('^whois @(.*)')
        function id_by_username(extra,result,success)
          if result.id_ then
            text = '<code>شناسه:</code> [<b>'..result.id_..'</b>]\n<code>تعداد پیام های ارسالی:</code> [<b>'..(db:get(SUDO..'total:messages:'..msg.chat_id_..':'..result.id_) or 0)..'</b>]'
            else 
            text = '<code>کاربر مورد نظر یافت نشد!</code>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,id_by_username)
        end
          if text == 'id' then
            if tonumber(msg.reply_to_message_id_) == 0 then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه-گروه</code>: {<b>'..msg.chat_id_..'</b>}', 1, 'html')
          end
            end
			if text == 'pin' then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   bot.sendMessage(msg.chat_id_, msg.reply_to_message_id_, 1, "<code>>پیام مورد نظر شما پین شد.</code>", 1, 'html')
   end
			 if text == 'bot' then
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>BOT Online!</b>', 1, 'html')
      end
        if text and text:match('whois (%d+)') then
              local id = text:match('whois (%d+)')
            local text = 'برای مشاهده اطلاعات کاربر کلیک کنید.'
			--{"👤 برای مشاهده کاربر کلیک کنید!","Click to view User 👤"}
            tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=36, user_id_=id}}}}, dl_cb, nil)
              end
        if text == "whois" then
        function id_by_reply(extra, result, success)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه:</code> [<b>'..result.sender_user_id_..'</b>]\n<code>تعداد پیام های ارسالی:</code> [<b>'..(db:get(SUDO..'total:messages:'..msg.chat_id_..':'..result.sender_user_id_) or 0)..'</b>]', 1, 'html')
        end
         if tonumber(msg.reply_to_message_id_) == 0 then
          else
    bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),id_by_reply)
      end
        end

          end
        end
      end
   -- member
   if text == 'ping' then
          local a = {"<code>ربات فعال و آماده کار است.</code>","<code>ربات فعال است</code>","<b>pong!</b>"}
          bot.sendMessage(msg.chat_id_, msg.id_, 1,''..a[math.random(#a)]..'', 1, 'html')
      end
	  db:incr("allmsg")
	  if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not db:sismember("botgp",msg.chat_id_) then  
            db:sadd("botgp",msg.chat_id_)
			 -- db:incrby("g:pa")
        end
        elseif id:match('^(%d+)') then
        if not db:sismember("usersbot",msg.chat_id_) then
            db:sadd("usersbot",msg.chat_id_)
			--db:incrby("pv:mm")
        end
        else
        if not db:sismember("botgp",msg.chat_id_) then
            db:sadd("botgp",msg.chat_id_)
			 -- db:incrby("g:pa")
        end
     end
    end
	  if text == 'number' then
         local number = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","43","45","46","47","48","49","50"}  
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>Your Random Number:</b>\n [<code>'..number[math.random(#number)]..'</code>]', 1, 'html')
      end
    if text and msg_type == 'text' and not is_muted(msg.chat_id_,msg.sender_user_id_) then
       if text == "me" then
         local msgs = db:get(SUDO..'total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>شناسه:</code> [<b>'..msg.sender_user_id_..'</b>]\n<code>تعداد پیام ها:</code> [<b>'..msgs..'</b>]', 1, 'html')
      end
end
end
  
  
  -- help 
  if text and text == 'help' then
    if is_sudo(msg) then
help = [[متن راهنمای مالک ربات ثبت نشده است.]]

  elseif is_owner(msg) then
    help = [[
	<code>>راهنمای مالکین گروه(اصلی-فرعی)</code>

*<b>[/#!]settings</b> --<code>دریافت تنظیمات گروه</code>
*<b>[/#!]setrules</b> --<code>تنظیم قوانین گروه</code>
*<b>[/#!]modset</b> @username|reply|user-id --<code>تنظیم مالک فرعی جدید برای گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]moddem</b> @username|reply|user-id --<code>حذف مالک فرعی از گروه با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]ownerlist</b> --<code>دریافت لیست مدیران اصلی</code>
*<b>[/#!]managers</b> --<code>دریافت لیست مدیران فرعی گروه</code>
*<b>[/#!]setlink</b> <code>link</code> <code>{لینک-گروه} --تنظیم لینک گروه</code>
*<b>[/#!]link</b> <code>دریافت لینک گروه</code>
*<b>[/#!]kick</b> @username|reply|user-id <code>اخراج کاربر با ریپلی|یوزرنیم|شناسه</code>
<b>-------------------------------</b>
<code>>راهنمای بخش حذف ها</code>
*<b>[/#!]delete managers</b> <code>{حذف تمامی مدیران فرعی تنظیم شده برای گروه}</code>
*<b>[/#!]delete welcome</b> <code>{حذف پیغام خوش آمدگویی تنظیم شده برای گروه}</code>
*<b>[/#!]delete bots</b> <code>{حذف تمامی ربات های موجود در ابرگروه}</code>
*<b>[/#!]delete silentlist</b> <code>{حذف لیست سکوت کاربران}</code>
*<b>[/#!]delete filterlist</b> <code>{حذف لیست کلمات فیلتر شده در گروه}</code>
<b>-------------------------------</b>
<code>>راهنمای بخش خوش آمدگویی</code>
*<b>[/#!]welcome enable</b> --<code>(فعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]welcome disable</b> --<code>(غیرفعال کردن پیغام خوش آمدگویی در گروه)</code>
*<b>[/#!]setwelcome text</b> --<code>(تنظیم پیغام خوش آمدگویی جدید در گروه)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلترگروه</code>
*<b>[/#!]mutechat</b> --<code>فعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]unmutechat</b> --<code>غیرفعال کردن فیلتر تمامی گفتگو ها</code>
*<b>[/#!]mutechat number(h|m|s)</b> --<code>فیلتر تمامی گفتگو ها بر حسب زمان[ساعت|دقیقه|ثانیه]</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات حالت سکوت کاربران</code>
*<b>[/#!]silentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]unsilentuser</b> @username|reply|user-id <code>--افزودن کاربر به لیست سکوت با یوزرنیم|ریپلی|شناسه -فرد</code>
*<b>[/#!]silentlist</b> <code>--دریافت لیست کاربران حالت سکوت</code>
<b>-------------------------------</b>
<code>>راهنمای بخش فیلتر-کلمات</code>
*<b>[/#!]filter word</b> <code>--افزودن عبارت جدید به لیست کلمات فیلتر شده</code>
*<b>[/#!]unfilter word</b> <code>--حذف عبارت جدید از لیست کلمات فیلتر شده</code>
*<b>[/#!]filterlist</b> <code>--دریافت لیست کلمات فیلتر شده</code>
<b>-------------------------------</b>
<code>>راهنمای دستورات تنظیمات ابر-گروه[فیلترها]</code>
*<b>[/#!]lock|unlock link</b> --<code>(فعال سازی/غیرفعال سازی ارسال تبلیغات)</code>
*<b>[/#!]lock|unlock username</b> --<code>(فعال سازی/غیرفعال سازی ارسال یوزرنیم)</code>
*<b>[/#!]lock|unlock sticker</b> --<code>(فعال سازی/غیرفعال سازی ارسال برچسب)</code>
*<b>[/#!]lock|unlock contact</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  مخاطبین)</code>
*<b>[/#!]lock|unlock english</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(انگلیسی))</code>
*<b>[/#!]lock|unlock persian</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  گفتمان(فارسی))</code>
*<b>[/#!]lock|unlock forward</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  فوروارد)</code>
*<b>[/#!]lock|unlock photo</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  تصاویر)</code>
*<b>[/#!]lock|unlock video</b> --<code>(فعال سازی/غیرفعال سازی فیلتر ویدئو)</code>
*<b>[/#!]lock|unlock gif</b> --<code>(فعال سازی/غیرفعال سازی فیلتر تصاویر-متحرک)</code>
*<b>[/#!]lock|unlock music</b> --<code>(فعال سازی/غیرفعال سازی فیلتر آهنگ(MP3))</code>
*<b>[/#!]lock|unlock audio</b> --<code>(فعال سازی/غیرفعال سازی فیلتر صدا(Voice-Audio))</code>
*<b>[/#!]lock|unlock text</b> --<code>(فعال سازی/غیرفعال سازی فیلتر متن)</code>
*<b>[/#!]lock|unlock keyboard</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  درون-خطی(کیبرد شیشه))</code>
*<b>[/#!]lock|unlock tgservice</b> --<code>(فعال سازی/غیرفعال سازی فیتلر  پیام ورود-خروج افراد)</code>
*<b>[/#!]lock|unlock pin</b> --<code>(مجاز/غیرمجاز کردن پین پیام توسط عضو عادی)</code>
*<b>[/#!]lock|unlock number(h|m|s)</b> --<code>(مجاز/غیرمجاز کردن ارسال پیغام مکرر)</code>
<b>-------------------------------</b>
<code>>راهنمای بخش تنظیم پیغام مکرر</code>
*<b>[/#!]floodmax number</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر</code>
*<b>[/#!]floodtime</b> --<code>تنظیم حساسیت نسبت به ارسال پیام مکرر برحسب زمان</code>
]]
   elseif is_mod(msg) then
    help = [[از متن راهنمای مالکین گروه استفاده کنید.]]
    elseif not is_mod(msg) then
    help = [[متن راهنما برای کاربران عادی ثبت نشده است.]]
    end
   bot.sendMessage(msg.chat_id_, msg.id_, 1, help, 1, 'html')
  end
  end
function tdcli_update_callback(data)
    if (data.ID == "UpdateNewMessage") then
     run(data.message_,data)
  elseif (data.ID == "UpdateMessageEdited") then
    data = data
    local function edited_cb(extra,result,success)
      run(result,data)
    end
     tdcli_function ({
      ID = "GetMessage",
      chat_id_ = data.chat_id_,
      message_id_ = data.message_id_
    }, edited_cb, nil)
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
