#!/bin/sh

set -e

boxname=$(whoami | sed 's:\.:/:')

# spreadsheet-install.sh
# Installs the ScraperWiki spreadsheet tool into this box.

(
cd ../http
git clone git://github.com/scraperwiki/spreadsheet-tool.git

sed -i "/^sqliteEndpoint/s@.*@sqliteEndpoint = '../../sqlite'; // Added by spreadsheet-install.sh@" spreadsheet-tool/js/spreadsheet-tool.js
)

# install CSV download tool
cat > download << 'EOF'
#!/bin/sh
dbfile=highrise/scraperwiki.sqlite
table_name=$(sqlite3 $dbfile 'select name from sqlite_master
where type="table" order by random() limit 1')
sqlite3 -header -csv $dbfile "select * from $table_name" > http/data.csv
EOF
chmod +x download

