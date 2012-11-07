#!/bin/sh
# spreadsheet-install.sh
# Installs the ScraperWiki spreadsheet tool into this box.

set -e

cd ../http
git clone git://github.com/scraperwiki/spreadsheet-tool.git


boxname=$(whoami | sed 's:\.:/:')
sed -i "/^sqliteEndpoint/s@.*@sqliteEndpoint = '../../sqlite'; // Added by spreadsheet-install.sh@" spreadsheet-tool/js/spreadsheet-tool.js

