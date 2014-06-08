#!/bin/sh
echo 'Content-Type: text/html'
echo

echo "<html> <head> <title> $REMOTE_ADDR </title> </head> <body> <center>"
echo

echo "<h3><b>WELCOME $REMOTE_ADDR</b></h3>" 

argument=`echo "$QUERY_STRING" | sed "s|mode=||"`

echo $argument
echo "Select which connection do you want to use:<br><br>"
echo '<form method="GET" action="">'
echo '<select name="mode">'
echo '<option value="4g" selected="selected">three.ie 4g</option>'
echo '<option value="vpn">VPN crisidev.org</option>'
echo '</select>'
echo '<input type="submit" value="Submit">'
echo '</form>'

if [ "$argument" = "4g" ] || [ "$argument" = "vpn" ]; then
	/etc/change_route.sh $REMOTE_ADDR $argument
	echo "<h3>$REMOTE_ADDR routed through $argument - OK</h3>"
fi

echo '</center> </body> </html>'
