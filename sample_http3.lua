function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
function urldecode(payload)
    result = {};
    list=split(payload,"\r\n")
    list=split(list[1]," ")
    list=split(list[2],"\/")
    table.insert(result, list[1]);
    table.insert(result, list[2]);
    table.insert(result, list[3]);
    return result;
end

function index(conn)
    gpio5 = 'ON'
    gpio6 = 'ON'
    gpio7 = 'ON'
    if (gpio.read(5) == 1) then
       gpio5 = 'OFF'
    end
    if (gpio.read(6) == 1) then
       gpio6 = 'OFF'
    end
    if (gpio.read(7) == 1) then
       gpio7 = 'OFF'
    end    
    conn:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nAccess-Control-Allow-Origin: *\r\nCache-Control: private, no-store\r\n\r\n\
     <!DOCTYPE HTML><html><head><style>input[type=submit] {font-size:large;width:8em;height:4em;}</style>\
     <meta content="text/html;charset=utf-8"><title>ESP8266</title>\
     <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">\
     <body bgcolor="#ffe4c4"><a href="/"><h2>ESP8266-12</h2></a><hr>\
     <form action="/digital/5/'..gpio.read(5)..'" method="POST"><input type="submit" value="GPIO5 '..gpio5..'" /></form><br>\
     <form action="/digital/6/'..gpio.read(6)..'" method="POST"><input type="submit" value="GPIO6 '..gpio6..'" /></form><br>\
     <form action="/digital/7/'..gpio.read(7)..'" method="POST"><input type="submit" value="GPIO7 '..gpio7..'" /></form>\
     </body></html>')
end
function notfound(conn)
     conn:send('HTTP/1.1 404 Not Found\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
          <!DOCTYPE HTML>\
         <html><head><meta content="text/html;charset=utf-8"><title>ESP8266</title></head>\
          <body bgcolor="#ffe4c4"><h2>Page Not Found</h2>\
          </body></html>') 
end

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
      print("Http Request..\r\n")
      --print (payload)
      list=urldecode(payload) 
      if ((list[2]=="") or (list[2]=="index.html")) then 
          index(conn)   
      elseif (list[2]=="digital") then
          local pin = tonumber(list[3]) 
          local status = tonumber(list[4]) 
          if (status == 1) then
               gpio.write(pin, 0)   
          else
               gpio.write(pin, 1)
          end  
          --print(gpio.read(pin))        
          index(conn)
      else
          notfound(conn)   
      end      
      conn:close() 
    end)
end)
