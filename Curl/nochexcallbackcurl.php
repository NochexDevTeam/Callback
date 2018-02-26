<?php

ini_set("SMTP","mail.nochex.com" ); 
$header = "From: apc@nochex.com";

// Get the POST information from Nochex server
$postvars = http_build_query($_POST);

// Set parameters for the email
$to = "";

$url = "https://secure.nochex.com/callback/callback.aspx";
$ch = curl_init ();
curl_setopt ($ch, CURLOPT_URL, $url);
curl_setopt ($ch, CURLOPT_POST, true);
curl_setopt ($ch, CURLOPT_POSTFIELDS, $postvars);
curl_setopt ($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt ($ch, CURLOPT_SSL_VERIFYHOST, false);
curl_setopt ($ch, CURLOPT_SSL_VERIFYPEER, 0);
$response = curl_exec ($ch);
curl_close ($ch);

if($_POST["transaction_status"] == "100"){
$testStatus = "Test"; 
}else{
$testStatus = "Live";
}

// Put the variables in a printable format for the email
$debug = "IP -> " . $_SERVER['REMOTE_ADDR'] ."\r\n\r\nPOST DATA:\r\n"; 
foreach($_POST as $Index => $Value) 
$debug .= "$Index -> $Value\r\n"; 
$debug .= "\r\nRESPONSE:\r\n$response";

//If statement
if ($response=="AUTHORISED") {  // searches response to see if AUTHORISED is present if it isn’t a failure message is displayed

    $msg = "Callback was AUTHORISED.\r\n\r\n$debug"; // if AUTHORISED was found in the response then it was successful
   	
} else { 

	$msg = "Callback was not AUTHORISED.\r\n\r\n$debug";  // displays debug message
	
}

//Email the response
mail($to, 'APC', $msg, $header);
?>
