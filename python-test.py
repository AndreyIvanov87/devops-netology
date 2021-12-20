#!/usr/bin/env python3

import os
import sys

if (len(sys.argv)>1):
	path = sys.argv[1]
else:	
	path=os.getcwd()
	#path = '~/netology/devops-netology'
bash_command = ["cd "+path, "git status"]

result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('изменено') != -1:
        prepare_result = result.replace('\tизменено:      ', '')
        print(path+"/"+prepare_result)
        


