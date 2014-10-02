function load_reader_trigger(p)
  if(p == nil) then
    return {
      ref = "serverdensity_monitoring_trigger",
      name = "ServerDensity Auto Server Monitoring",
      description = "Automaticaly add server to ServerDensity",
      priority = 0,
      triggerType = "SCHEDULED",
      schedule={frequency={MINUTE=1}},
      api = "TRIGGER",
      version = 1,
    }
  end
 
  print("======== LOAD READER ACTIVATION =========")
    local f = io.open('/serverstatuslog/load.txt', 'r')
    f:seek('end', -1024)
    local text = f:read('*a')
    local after = string.match(text, ".*load(.*)")
    f:close()
    load = tonumber(after) 
     
        --ocal load = 20
        print('It worked ' .. after .. ' given.')
        if load >= 20  then
         print('It worked again ' .. load .. ' given.')
         -- set action baised on load
         local userToken = getUserToken(disk.customerUUID)
         userAPI:setSessionUser(userToken)
         local serverList = getServersWithKey('CACTOS_SERVER')
         for serverUUID,server in pairs(serverList) do
          local startServer = userAPI:changeServerStatus(serverUUID, new("ServerStatus","RUNNING"), true, nil, nil)
           print('Started')
        end
    end

    print("======== LOAD READER  TRIGGER ACTIVATION COMPLETE=========")

end
function getServersWithKey(resourceKeyName)
  local searchFilter = new("SearchFilter")
  local filterCondition1 = new("FilterCondition")
  filterCondition1:setField('status')
  filterCondition1:setValue({"STOPPED"})
  filterCondition1:setCondition(new("Condition","IS_EQUAL_TO"))
  local filterCondition2 = new("FilterCondition")
  filterCondition2:setField('resourcekey.name')
  filterCondition2:setValue({resourceKeyName})
  filterCondition2:setCondition(new("Condition","STARTS_WITH"))
  searchFilter:addCondition(filterCondition1)
  searchFilter:addCondition(filterCondition2)
  local servers = adminAPI:listResources(searchFilter,nil,new("ResourceType","SERVER"))
  local responseData = {}
  for i = 0, servers:getList():size() - 1, 1 do
    responseData[servers:getList():get(i):getResourceUUID()] = {snapshotTime = getResourceKeyValue(resourceKeyName,servers:getList():get(i):getResourceKey()) , customerUUID = servers:getList():get(i):getCustomerUUID()}
  end
  return responseData
end

function getUserToken(customerUUID)
  local searchFilter = new("SearchFilter")
  local filterCondition1 = new("FilterCondition")
  filterCondition1:setField('resourceuuid')
  filterCondition1:setValue({customerUUID})
  filterCondition1:setCondition(new("Condition","IS_EQUAL_TO"))
  searchFilter:addCondition(filterCondition1)
  local customer = adminAPI:listResources(searchFilter,nil,new("ResourceType","CUSTOMER"))
  local userEmail = customer:getList():get(0):getUsers():get(0):getEmail()

  return userEmail .. "/" .. customer:getList():get(0):getResourceUUID()
end

function register()
  return {"load_reader_trigger"}
end