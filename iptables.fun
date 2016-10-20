*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [225264:30323816]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -m recent --rcheck --seconds 86400 --name portscan --mask 255.255.255.255 --rsource -j LOG --log-prefix "Dropping Portscanner: "
-A INPUT -m recent --rcheck --seconds 86400 --name portscan --mask 255.255.255.255 --rsource -j DROP
-A INPUT -m recent --remove --name portscan --mask 255.255.255.255 --rsource
-A INPUT -s 127.0.0.1/32 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -m recent --set --name portscan --mask 255.255.255.255 --rsource -j LOG --log-prefix "Portscan:"
-A INPUT -j LOG --log-prefix "Dropping:"
-A INPUT -j DROP
COMMIT
