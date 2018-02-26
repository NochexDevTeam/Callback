<%@ Page Language="VB" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
<% 
    Try
       
		' Get all the POST details into a NameValueCollection
        Dim nvc As NameValueCollection = Request.Form
        
		
        'Uncomment below to force a DECLINED response
        'nvc = Request.GetType.GetField("_form", Reflection.BindingFlags.NonPublic Or Reflection.BindingFlags.Instance).GetValue(Request)
        'Dim readable As Reflection.PropertyInfo = nvc.GetType.GetProperty("IsReadOnly", Reflection.BindingFlags.NonPublic Or Reflection.BindingFlags.Instance)
        'readable.SetValue(nvc, False, Nothing)
        'nvc("order_id") = "1"
        'readable.SetValue(nvc, True, Nothing)
        Dim toEmail As String = nvc("merchant_id")
        ' Get all the POST details from the NameValueCollection and convert to String
        Dim postdetails As String = nvc.ToString
        
        ' Create a request to the Nochex server.
        Dim webrequest As Net.HttpWebRequest = Net.WebRequest.Create("https://secure.nochex.com/callback/callback.aspx")
		' Set as a POST request.
        webrequest.Method = "POST" 
        webrequest.ContentType = "application/x-www-form-urlencoded"
		' Encode the POST details into bytes.
        Dim byteArray As Byte() = Encoding.UTF8.GetBytes(postdetails) 
        webrequest.ContentLength = byteArray.Length
        
        ' Create a stream object to send the POST details.
        Dim dataStream As IO.Stream = webrequest.GetRequestStream
		' Write data to the stream object.
        dataStream.Write(byteArray, 0, byteArray.Length) 
		' Close the data stream object.
        dataStream.Close() 
        
        ' Get the response.  
        Dim webresponse As Net.HttpWebResponse = webrequest.GetResponse
		' Create reader to get response.
        Dim reader As New IO.StreamReader(webresponse.GetResponseStream) 
		' Return the APC response as a String.
        Dim apcresponse As String = reader.ReadToEnd 
		' Close the reader.
        reader.Close()
        
        If (apcresponse = "AUTHORISED") Then
            ' If APC repsonse is AUTHORISED do something.
            
			' Create a mail object.
            Dim mail As New Net.Mail.MailMessage() 
			' Set SMTP details and port if required.
            Dim smtpClient As New Net.Mail.SmtpClient("mail.nochex.com") 
			
            ' Add credentials if the SMTP server requires them.
            ' smtpClient.Credentials = Net.CredentialCache.DefaultNetworkCredentials
            
            ' Specify the from and to email address along with the subject and body Strings.
			' The sender of the email.
            mail.From = New Net.Mail.MailAddress("apc@nochex.com") 
			' The recipient of the email.
            mail.To.Add(""+ toEmail +"") 
			'Subject of the email, which should reflect the apc response, this should be Authorised.
            mail.Subject = "APC AUTHORISED" 
			' Contents of the email which will display the response of the APC. The response should be Authorised.
            mail.Body = "-- APC Response: " + apcresponse
            
            Dim formvalues As NameValueCollection = Request.Form
			' Loop through the POST details and attaches them to the email body after the response of the apc. These variables are collected from the APC Post.
            For Each formkey As String In formvalues.AllKeys
				 mail.Body += Environment.NewLine + " -- " + formkey + " -- " + formvalues(formkey)
            Next
			
            ' Sends the complete email. (Headers, Subject, Contents.)
            smtpClient.Send(mail)
            
        Else 
			' If the APC response is DECLINED email results and investigate
			
			' Create a mail object
            Dim mail As New Net.Mail.MailMessage() 
			
			' Set SMTP details and port if required
            Dim smtpClient As New Net.Mail.SmtpClient("mail.nochex.com")
			
            ' Add credentials if the SMTP server requires them.
            ' smtpClient.Credentials = Net.CredentialCache.DefaultNetworkCredentials
            
            ' Specify the from and to email address along with the subject and body Strings.			
			' The address of the sender.
            mail.From = New Net.Mail.MailAddress("apc@nochex.com")
			' The address of the recipient.
            mail.To.Add(""+ toEmail +"")
			' Subject of the email, which displays as Declined.
            mail.Subject = "APC DECLINED"
			' Contents of the email which will display the response of the APC. The response should be Declined.
            mail.Body = "-- APC Response: " + apcresponse
            
            Dim formvalues As NameValueCollection = Request.Form
			' Loop through the POST details and attaches them to the email body after the response of the apc. These variables are collected from the APC Post.
            For Each formkey As String In formvalues.AllKeys
                mail.Body += Environment.NewLine + " -- " + formkey + " -- " + formvalues(formkey) + ". "
            Next
			
            ' Sends the complete email. (Headers, Subject, Contents.)
            smtpClient.Send(mail)
        End If
        
    Catch ex As Exception ' If an exception occured. Email the reason for failure
		' Create a mail objection
        Dim mail As New Net.Mail.MailMessage() 
		' Set SMTP details and port if required
        Dim smtpClient As New Net.Mail.SmtpClient("mail.nochex.com") 
		
        ' Add credentials if the SMTP server requires them.
        ' smtpClient.Credentials = Net.CredentialCache.DefaultNetworkCredentials.
        
        ' Specify the from and to email address along with the subject and body Strings.
		' Sender of the Email.
        mail.From = New Net.Mail.MailAddress("apc@nochex.com")
		' Receipient of the Email.
		mail.To.Add(""+ toEmail +"") 
		' Subject of the email, displayed if the response is not declined or authorised.
        mail.Subject = "Error"	
		' The body of the email will be the error message.
        mail.Body = ex.Message 
        ' Sends the complete email. (Headers, Subject, Contents.)
        smtpClient.Send(mail)
    End Try
%>   
     
    </div>
    </form>
</body>
</html>
