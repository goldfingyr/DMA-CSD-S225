#!/bin/bash

echo -e "Content-type: text/html\n"
echo "<html>"
echo "  <body>"
echo "    <h1>My Secure Website</h1>"
echo "    <h5>Environment</h5>"
export | awk '{print $0 "<br>"}'
echo "  </body>"
echo "</html>"

