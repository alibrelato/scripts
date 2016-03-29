#!/bin/sh

echo "DATAHORA=\`date +%Y-%m-%d_%H%M%S\`"    >  copy.sh
echo "echo \$DATAHORA > /bkp/shb1/copia.log" >> copy.sh

total=0;
total1=0;
total2=0;

while read line
do
    size=`stat -c%s $line`;
    total=$(($total + $size));
    if test $total -gt 550000000000
    then
        total2=$(($total2 + $size));
        echo "cp "$line" /bkp2/";
        #echo "cp "$line" /bkp2/" >> copy.sh;
    else
        total1=$(($total1 + $size));
        echo "cp "$line" /bkp/";
        #echo "cp "$line" /bkp/" >> copy.sh;
    fi
done < newwdb.shb1.txt

echo "DATAHORA=\`date +%Y-%m-%d_%H%M%S\`"     >>  copy.sh
echo "echo \$DATAHORA >> /bkp/shb1/copia.log" >> copy.sh
chmod 777 copy.sh
echo "total em /bkp/  "$total1;
echo "total em /bkp2/ "$total2;