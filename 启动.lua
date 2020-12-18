os.execute 'taskkill /f /im nginx.exe'
--os.execute 'taskkill /f /im luajit-task.exe'
os.execute 'start nginx'
--os.execute 'luajit-task.exe script/task.lua'
