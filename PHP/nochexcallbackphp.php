<?php 
// Payment confirmation from http post 
ini_set("SMTP","mail.nochex.com" ); 
$header = "From: callback@nochex.com";
  
$your_email = '';  // your merchant account email address

  
function http_post($server, $port, $url, $vars) { 
    // get urlencoded vesion of $vars array 
    $urlencoded = ""; 
    foreach ($vars as $Index => $Value) // loop round variables and encode them to be used in query
    $urlencoded .= urlencode($Index ) . "=" . urlencode($Value) . "&"; 
    $urlencoded = substr($urlencoded,0,-1);   // returns portion of string, everything but last character

    $headers = "POST $url HTTP/1.0\r\n";  // headers to be sent to the server
    $headers .= "Content-Type: application/x-www-form-urlencoded\r\n";
	$headers .= "Host: secure.nochex.com\r\n";
    $headers .= "Content-Length: ". strlen($urlencoded) . "\r\n\r\n";  // length of the string
		
	$hostip = @gethostbyname("secure.nochex.com");

	echo "Nochex IP Address = " . $hostip . "<br/><br/>";
	
	echo "Headers = " . $headers . "";
	
    $fp = fsockopen($server, $port, $errno, $errstr, 20);  // returns file pointer
    if (!$fp) return "ERROR: fsockopen failed.\r\nError no: $errno - $errstr";  // if cannot open socket then display error message
	
    fputs($fp, $headers);  //writes to file pointer

    fputs($fp, $urlencoded);  
  
    $ret = ""; 
    while (!feof($fp)) $ret .= fgets($fp, 1024); // while it’s not the end of the file it will loop 
    fclose($fp);  // closes the connection
    return $ret; // array 
} 


// uncomment below to force a DECLINED response 
//$_POST['order_id'] = "1"; 

$response = http_post("ssl://secure.nochex.com", 443, "/callback/callback.aspx", $_POST); 

			if ($_POST['transaction_status'] == "100"){
			$status = " TEST";
			}else{
			$status = " LIVE";
			}


$debug = "IP -> " . $_SERVER['REMOTE_ADDR'] ."\r\n\r\nPOST DATA:\r\n"; 
foreach($_POST as $Index => $Value) 
$debug .= "$Index -> $Value\r\n"; 
$debug .= "\r\nRESPONSE:\r\n$response";

echo $debug;
  
if (!strstr($response, "AUTHORISED"))  {
	$msg = "Callback was not AUTHORISED. \r\n\r\n$debug";  


}else{

  $msg = "Callback was AUTHORISED. \r\n\r\n$debug"; 


} 
 
mail($your_email, "APC Debug", $msg, $header);  // sends an email explaining whether APC was successful or not, the subject will be “APC Debug” but you can change this to whatever you want.
?>  
