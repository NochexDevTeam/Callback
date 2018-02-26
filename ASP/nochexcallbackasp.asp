<%@ Language=VBScript %>

<%

'requires Microsoft XML Parser http://msdn.microsoft.com/xml
Dim objHttp 'object used for posting form data to nochex
Dim nochexformdata 'variable used to store form data sent from Nochex
Dim NochexResponse 'stores the response from the Nochex server

nochexformdata = request.Form 'copy the form data from Nochex into the variable

set objHttp = Server.CreateObject("Microsoft.XMLHTTP") 'create an instance of the XML object library
objHttp.open "POST", "https://secure.nochex.com/callback/callback.aspx", false 'set the page to post the form data to the Nochex server
objHttp.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
objHttp.Send nochexformdata 'send the form data received from Nochex to the NOCHEX server

' Check notification validation
if (objHttp.status = 200 ) then
	if (objHttp.responseText = "AUTHORISED") then
		NochexResponse = "AUTHORISED"

	'check the transaction_id to make sure it is not a duplicate
	'process transaction
	elseif (objHttp.responseText = "DECLINED") then
		NochexResponse = "DECLINED"
		'log and investigate incorrect data
	end if
else
	NochexResponse = "NO RESPONSE "
end if

%>
