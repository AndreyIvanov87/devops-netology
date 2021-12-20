#!/usr/bin/env python3

import os
import sys

dictglob={}
f = open('/tmp/ip-log.txt','r')
for line in f:
	list1=list(line.split(" "))
	dictglob[list1[0]]=list1[1]
f.close()
#print(dictglob)

f = open('/tmp/ip-log.txt','w')
sitelist=("drive.google.com","mail.google.com","google.com")

for site in sitelist:
	bash_command=("host "+site+"| grep  address| head -n 1  | awk '{print $4}'")
	#print(bash_command)
	result_os = os.popen(bash_command).read()	
	print("http://"+site, " - ", result_os)
	if (dictglob[site] != result_os ):
		print("[ERROR]", "http://"+site, "IP mismatch:", dictglob[site] , result_os)
	f.write(site+" "+result_os)
f.close()
     


