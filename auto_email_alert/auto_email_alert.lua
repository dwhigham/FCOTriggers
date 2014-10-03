-- (c) 2013 Flexiant Ltd
-- Released under the Apache 2.0 Licence - see LICENCE for details

function auto_email_alert(p)
	if(p == nil) then
		return {
			ref = "shutdown_alert",
			name = "Alert on shutdown",
			description = "This trigger will automatically send a mail to a user if a server shuts down ",
			priority = 0,
			triggerType = "POST_JOB_STATE_CHANGE",
			triggerOptions = {"SUCCESSFUL"},
			api = "TRIGGER", 
			version = 1,
		}
	end

if(p.input:getJobType() == new("JobType","SHUTDOWN_SERVER")) then 
	local customerUUID = p.input:getCustomerUUID()
	customerCheck = checkCustomerKey(customerUUID, "EMAIL_RECP")
		if (customerCheck.success) then
		print("========== ALERT SERVER SHUTDOWN ==========")
				local beMail = getBEMail(p.beUUID)
				userEmail = p.user:getEmail()
				local dateHelper = new("FDLDateHelper")
				local modifiedDay = dateHelper:getString(dateHelper:getTimestamp()-(24*60*60*1000),"yyyy-MM-dd hh:mm:ssZ")
				message = " Hello system administrator, SERVER " .. p.input:getItemUUID() .. " has shutdown! " .. "Date modified " .. modifiedDay
				local serverList = getServerList()
				for i = 0, serverList.data:size() -1 ,1 do
				checkServer(serverList.data:get(i))

		print("========== ALERT SERVER SHUTDOWN EMAIL SENT ==========")
		end
	end
	return { exitState = "SUCCESS" }
end

end

function sendMail(toEmail, beMail, msg)
	local emailHelper = new("FDLEmailHelper")
	emailHelper:sendEmail(toEmail, beMail, beMail, nil, nil, "SERVER SHUTDOWN ALERT", msg, nil)
end

function getServerList()
	local searchFilter = new("SearchFilter")
	local filterCondition1 = new("FilterCondition")
	filterCondition1:setField('resourcekey.name')
	filterCondition1:setValue({'ALERT_SERVER'})
	filterCondition1:setCondition(new("Condition","IS_EQUAL_TO"))
	searchFilter:addCondition(filterCondition1)
	local servers = adminAPI:listResources(searchFilter,nil,new("ResourceType","SERVER"))

	if(servers:getList():size() > 0) then
		return {success = true, data = servers:getList()}
		
	else
		return {success = false}
	end
end

function checkServer(server)
	for i = 0, server:getResourceKey():size() - server:getResourceKey():size()+1, 1 do
		if(server:getResourceKey():get(i):getName() == 'ALERT_SERVER') then
			print('Sending  email to : ' .. customerCheck.keyValue)
				sendMail(customerCheck.keyValue, beMail, message)
		end
	end

end

function checkCustomerKey(customerUUID, resourceKeyName)
	local searchFilter = new("SearchFilter")
	local filterCondition1 = new("FilterCondition")
	filterCondition1:setField('resourceuuid')
	filterCondition1:setValue({customerUUID})
	filterCondition1:setCondition(new("Condition","IS_EQUAL_TO"))
	local filterCondition2 = new("FilterCondition")
	filterCondition2:setField('resourcekey.name')
	filterCondition2:setValue({resourceKeyName})
	filterCondition2:setCondition(new("Condition","IS_EQUAL_TO"))
	searchFilter:addCondition(filterCondition1)
	searchFilter:addCondition(filterCondition2)
	local customer = adminAPI:listResources(searchFilter,nil,new("ResourceType","CUSTOMER"))
	if(customer:getList():size() == 1) then
		for i = 0, customer:getList():get(0):getResourceKey():size() - 1, 1 do
			if(customer:getList():get(0):getResourceKey():get(i):getName() == resourceKeyName) then
				return {success = true, keyValue = customer:getList():get(0):getResourceKey():get(i):getValue() }
			end
		end
	else
		return {success = false}
	end
end


function getBEMail(beUUID)
	local searchFilter = new("SearchFilter")
	local filterCondition1 = new("FilterCondition")
	filterCondition1:setField('billingentityuuid')
	filterCondition1:setValue({beUUID})
	filterCondition1:setCondition(new("Condition","IS_EQUAL_TO"))
	local filterCondition2 = new("FilterCondition")
	filterCondition2:setField('status')
	filterCondition2:setValue({"ADMIN"})
	filterCondition2:setCondition(new("Condition","IS_EQUAL_TO"))
	searchFilter:addCondition(filterCondition1)
	searchFilter:addCondition(filterCondition2)

	local customer = adminAPI:listResources(searchFilter,nil,new("ResourceType","CUSTOMER"))

	local userEmail = customer:getList():get(0):getUsers():get(0):getEmail()
	return userEmail
end

function checkBeKey(beUUID, resourceKeyName)
	local searchFilter = new("SearchFilter")
	local filterCondition1 = new("FilterCondition")
	filterCondition1:setField('resourceuuid')
	filterCondition1:setValue({beUUID})
	filterCondition1:setCondition(new("Condition","IS_EQUAL_TO"))
	local filterCondition2 = new("FilterCondition")
	filterCondition2:setField('resourcekey.name')
	filterCondition2:setValue({resourceKeyName})
	filterCondition2:setCondition(new("Condition","IS_EQUAL_TO"))
	searchFilter:addCondition(filterCondition1)
	searchFilter:addCondition(filterCondition2)
	local billingEntity = adminAPI:listResources(searchFilter,nil,new("ResourceType","BILLING_ENTITY"))
	if(billingEntity:getList():size() == 1) then
		for i = 0, billingEntity:getList():get(0):getResourceKey():size() - 1, 1 do
			if(billingEntity:getList():get(0):getResourceKey():get(i):getName() == resourceKeyName) then
				return {success = true, keyValue = billingEntity:getList():get(0):getResourceKey():get(i):getValue() }
			end
		end
	else
		return {success = false}
	end
end

function register()
	return {
	"auto_email_alert"
	}
end