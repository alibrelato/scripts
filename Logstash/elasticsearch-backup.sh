#!/usr/bin/env bash
 
###############FUNCTIONS############
 
function prepare {
#optimize the index
echo -n "Optimizing index $INDEX_NAME..."
curl -XPOST "$ADDRESS/$INDEX_NAME/_optimize" 2>/dev/null| grep 'failed":0' >/dev/null
if [ $? -eq 0 ]; then
echo "done"
else
echo "failed. Moving on..."
fi
#make the index read-only
echo -n "Disabling writes on $INDEX_NAME..."
RESULT=`curl -XPUT "$ADDRESS/$INDEX_NAME/_settings" -d '{
"index": {
"blocks.write": true
}
}' 2>/dev/null`
if [ "$RESULT" = '{"ok":true}' ]; then
echo "OK"
else
echo "FAILED"
echo "Nasty error appeared. Exiting prematurely..."
exit 1
fi
#disable flush on the given index
echo -n "Flushing index $INDEX_NAME..."
RESULT=`curl -XPUT "$ADDRESS/$INDEX_NAME/_settings" -d '{
"index": {
"translog.disable_flush": true
}
}' 2>/dev/null`
if [ "$RESULT" = '{"ok":true}' ]; then
echo "OK"
else
echo "FAILED"
echo "Nasty error appeared. Exiting prematurely..."
exit 1
fi
}
 
function cleanup {
#re-enable flush
echo -n "Enable flush on index $INDEX_NAME..."
RESULT=`curl -XPUT "$ADDRESS/$INDEX_NAME/_settings" -d '{
"index": {
"translog.disable_flush": false
}
}' 2>/dev/null`
if [ "$RESULT" = '{"ok":true}' ]; then
echo "OK"
else
echo "FAILED"
return 1
fi
}
 
function backup {
#tries to find the index in the given data dir
#then backs it up
echo -n "Attempting to find the data dir of the index..."
INDEX_DIR=`find $DATADIR -type d -name $INDEX_NAME`
if [ -d "$INDEX_DIR" ]; then
echo "OK"
else
echo "FAILED"
if [ -z "$INDEX_DIR" ]; then
echo "No directory was find by the name $INDEX_NAME in $DATADIR. Is your --datadir correct?"
else
echo "This is what I got while searching for $INDEX_NAME in $DATADIR: <$INDEX_DIR>"
fi
echo "Exiting..."
exit 1
fi
#now let's back it up
cd `dirname $INDEX_DIR`
echo -n "BZipping the index..."
tar --checkpoint=100 --checkpoint-action=exec="echo -n ." -cjf $BACKUP_LOCATION/$INDEX_NAME.tar.bz2 $INDEX_NAME >/dev/null 2>&1
if [ $? -eq 0 ]; then
echo "done"
else
echo "FAILED"
echo "Nasty error appeared. Exiting prematurely..."
exit 1
fi
}
 
function get_arguments {
for ARGUMENT in "$@"; do
case "$ARGUMENT" in
-h|--help)
echo "This will back up indices from Elasticsearch containing logs."
echo "It blindly relies on the fact that you have one index per day,"
echo "and the fact that you named your indices in the YYYY-MM-DD format"
echo
echo "Arguments:"
echo "-h|--help Shows this text"
echo "--index=INDEX_NAME Index to be backed up. Defaults to yesterday's index"
echo "--location=/P/A/T/H/ Where to backup the index. Defaults to /srv/"
echo "--address=host:port Where I can find an Elasticsearch node with HTTP transport enabled."
echo " Defaults to localhost:9200"
echo "--datadir=/P/A/T/H/ Where to search for the directory with the data of your index."
echo " It should be safe to fill in the ES data dir here."
echo " Defaults to /var/lib/elasticsearch/"
exit 0
;;
--index=*)
INDEX_NAME=`echo $ARGUMENT | cut -d "=" -f2-`
;;
--location=*)
BACKUP_LOCATION=`echo $ARGUMENT | cut -d "=" -f2-`
;;
--address=*)
ADDRESS=`echo $ARGUMENT | cut -d "=" -f2-`
;;
--datadir=*)
DATADIR=`echo $ARGUMENT | cut -d "=" -f2-`
;;
*)
echo "Invalid argument $ARGUMENT. Exiting now..."
echo "Tip: try --help"
exit 2
;;
esac
done
#now set the default values for stuff that wasn't defined
if [ -z "$INDEX_NAME" ]; then
INDEX_NAME=`date -d '1 day ago' +'%Y-%m-%d'` #index to back up is the one from yesterday
fi
if [ -z "$ADDRESS" ]; then
ADDRESS="localhost:9200" #for connecting to Elasticsearch via HTTP
fi
if [ -z "$BACKUP_LOCATION" ]; then
BACKUP_LOCATION="/srv/" #where to back up stuff
fi
if [ -z "$DATADIR" ]; then
DATADIR="/var/lib/elasticsearch/" #where I can expect to find the index
fi
}
###############MAIN#################
 
get_arguments $@
prepare
backup
cleanup
exit $?
