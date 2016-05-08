## Set up proxy to listen on 9050, in this case, TOR is easiest most obvious
## This is a great way to bypass proxy restrictions, or anonymously snag files.
## Check out grifsec.com/fetcher.php for a demo

<?php
	if(isset($_GET['url'])) {


		$maxsize = 104857600; #100megs
		$passwd = ""; 

		parse_str($_SERVER['QUERY_STRING']);

		$ch = curl_init();

		curl_setopt($ch, CURLOPT_PROXYTYPE, CURLPROXY_SOCKS5);
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_PROXY, '127.0.0.1:9050'); # over tor
		curl_setopt($ch, CURLOPT_NOBODY, TRUE); #headers only

		curl_exec($ch);

		$filesize = curl_getinfo($ch, CURLINFO_CONTENT_LENGTH_DOWNLOAD);  #check filesize to compare to $maxsize
		$content_type = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);

		if ($filesize < $maxsize || $passwd == "SETPASSWORD") {  ## Check password compare to passwd querystring 
			header('Content-Type: ' . $content_type);

			curl_setopt($ch, CURLOPT_NOBODY, FALSE); 
			$curled = curl_exec($ch);

			#$curled = gzcompress($curled); ## todo, fix this
			$curled;
			

		} else {

			echo "File too large";

		}

	
		curl_close($ch);
		exit;

	}
?>


<style type="text/css">

blink {
        color: inherit;
        animation: blink 1s steps(1) infinite;
        -webkit-animation: blink 1s steps(1) infinite;
}
@keyframes blink { 50% { color: transparent; } }
@-webkit-keyframes blink { 50% { color: transparent; } }

#leetassgriffin {
        color: red;
        float: left;
        left: 1em;
        font-size:.55vw;
}
leet {
        display: inline-block;
        font-family: monospace;
        text-shadow: 0 0 20px, 0 0 80px, 0 0 100px;
        font-size:1.2vw;
}

body {
        background-color: black;
}

#cashmoney {
        float: center;
        color: goldenrod;
}


</style>
<title>Griffin's Talon file Snatching utility!</title>
<html>
<body>


	<center>
	<div id="cashmoney">
	<leet>
	<h1>THE GRIFFIN'S TALON!</h1>
<marquee direction="right">
<pre>


      '\
       _\______
      / GRIFSEC\========                        apt
 ____|__________\_____                         \ ()
/ ___________________ \                         -|--
\/ _===============_ \/                         /\
  "-===============-"                          / /


</pre>
</marquee>
	<form action="fetcher.php" method="get">

		Url: <input type="text" name="url"><br>
		<input type="submit" value="Snag it!">

	</form>
	<div style="font-size:.8vw;">( *response is returned with same mime-type, so browser will try to handle<br> use with curl, query param=url, for easy file download )</div>
	</center>
</leet>
</div>
</body>
</html>
