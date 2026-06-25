--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

verifyBtn.MouseButton1Click:Connect(function() local v0=0 -0 ;local v1;local v2;while true do if (v0==(1 -0)) then v1,v2=pcall(function() return game:HttpGet("https://raw.githubusercontent.com/Sqayss/Sqays-Hub/refs/heads/main/key.json");end);if v1 then local v3=HttpService:JSONDecode(v2);local v4=os.date("!%Y-%m-%d");local v5=input.Text:gsub("%s+","");if (v5==v3.master_key) then local v8=1065 -(68 + 997) ;while true do if (v8==(1270 -(226 + 1044))) then gui:Destroy();task.wait(0.5 -0 );v8=1;end if (v8==(118 -(32 + 85))) then loadstring(game:HttpGet("https://pastebin.com/raw/2e4DjUVY"))();return;end end end local v6=false;if v3.keys[v4] then for v11,v12 in pairs(v3.keys[v4]) do if (v12==v5) then v6=true;break;end end end if v6 then local v9=0;while true do if (v9==(1 + 0)) then loadstring(game:HttpGet("https://pastebin.com/raw/2e4DjUVY"))();break;end if (v9==0) then gui:Destroy();task.wait(0.5 + 0 );v9=1;end end else local v10=0;while true do if (v10==1) then input.Text="";isProcessing=false;break;end if (v10==0) then input.Text="Invalid or Expired!";task.wait(958.5 -(892 + 65) );v10=2 -1 ;end end end else local v7=0 -0 ;while true do if (v7==(1 -0)) then input.Text="";isProcessing=false;break;end if ((350 -(87 + 263))==v7) then input.Text="Network Error!";task.wait(181.5 -(67 + 113) );v7=1 + 0 ;end end end break;end if (v0==(0 -0)) then if isProcessing then return;end isProcessing=true;v0=1 + 0 ;end end end);
