#!/usr/bin/env bash
 
###############FUNCTIONS############
 
function get_arguments {
for ARGUMENT in "$@"; do
case "$ARGUMENT" in
-h|--help)
echo "This will restpre indices from backup tp Elasticsearch."
echo
echo "Arguments:"
echo "-h|--help Shows this text"
echo "--file=INDEX_NAME BZip archive with the index contents"
echo "--destination=/P/A/T/H/ Where to extract index contents. Wildcards are allowed,"
echo " but dangerous, in case there's more than one match"
echo " Defaults to /var/lib/elasticsearch/elasticsearch*/nodes/0/indices"
exit 0
;;
--file=*)
FILE=`echo $ARGUMENT | cut -d "=" -f2-`
;;
--destination=*)
DESTINATION=`echo $ARGUMENT | cut -d "=" -f2-`
;;
*)
echo "Invalid argument $ARGUMENT. Exiting now..."
echo "Tip: try --help"
exit 2
;;
esac
done
#now set the default values for stuff that wasn't defined
if [ -z "$FILE" ]; then
echo "You need to specify a backup file to restore"
exit 2
fi
if [ -z "$DESTINATION" ]; then
DESTINATION="/var/lib/elasticsearch/elasticsearch*/nodes/0/indices" #where I can expect to find the index
fi
}
 
###############MAIN#################
 
get_arguments $@
echo -n "Extracting $FILE to $DESTINATION..."
tar jxf $FILE -C $DESTINATION >/dev/null 2>&1
if [ $? -eq 0 ]; then
echo "done"
else
echo "FAILED"
exit 1
fi
echo -n "Restarting Elasticsearch..."
/etc/init.d/elasticsearch restart >/dev/null 2>&1
if [ $? -eq 0 ]; then
echo "done"
else
echo "FAILED"
exit 1
fi
