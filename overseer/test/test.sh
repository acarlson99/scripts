date >> /tmp/testLog.log
echo $@ >> /tmp/testLog.log

sleep 5

if [ $((RANDOM % 2)) -eq 1 ]; then
	echo 'good' && date # stdout
else
	>&2 echo 'error' && >&2 date # stderr
fi
