#!/bin/bash
# Performs 'rotation' of ES indices. Maintains only 8 indicies (1 week) of logstash logs; this script
# is to be run at midnight daily and removes the oldest one (as well as any 1970s-era log indices,
# as these are a product of timestamp fail).  Please note the insane amount of error-checking
# in this script, as ES would rather delete everything than nothing...

# Before we do anything, let's get rid of any nasty 1970s-era indices we have floating around
TIMESTAMPFAIL=`curl -s localhost:9200/_status?pretty=true |grep index |grep log |sort |uniq |awk -F\" '{print $4}' |grep 1970 |wc -l`
if [ -n $TIMESTAMPFAIL ]
	then
		curl -s localhost:9200/_status?pretty=true |grep index |grep log |sort |uniq |awk -F\" '{print $4}' |grep 1970 | while read line
			do
				echo "Indices with screwed-up timestamps found; removing"
				echo -n "Deleting index $line: "
				curl -s -XDELETE http://localhost:9200/$line/
				echo "DONE!"
			done
fi


# Get list of indices; should we rotate?
INDEXCOUNT=`curl -s localhost:9200/_status?pretty=true |grep index |grep log |sort |uniq |awk -F\" '{print $4}' |wc -l`
if [ $INDEXCOUNT -lt "9" ] 
	then
		echo "Less than 8 indices, bailing with no action"
		exit 0
	else
		echo "More than 8 indices, time to do some cleaning"
		
		# Let's do some cleaning!
		OLDESTLOG=`curl -s localhost:9200/_status?pretty=true |grep index |grep log |sort |uniq |awk -F\" '{print $4}' |head -n1`
		echo -n "Deleting oldest index, $OLDESTLOG: "
		curl -s -XDELETE http://localhost:9200/$OLDESTLOG/
		echo "DONE!"
fi
