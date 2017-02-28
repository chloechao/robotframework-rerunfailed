#!/bin/sh
# This script file is to re-execute test cases and merge test result on Robot framework
# note: cannot execute command within single quote ', ex. -t 'test case'

# clean previous output files
rm -f report/output.xml
rm -f report/rerun.xml
rm -f report/first_run_log.html
rm -f report/second_run_log.html

run_with_tag=''

if [ ! -z "$TAG" ]; then
    run_with_tag='-i '$TAG
fi
 
echo
echo "#######################################"
echo "# Running portfolio a first time      #"
echo "#######################################"
echo
pybot $run_with_tag --outputdir report $@

# we stop the script here if all the tests were OK
if [ $? -eq 0 ]; then
    echo "we don't run the tests again as everything was OK on first try"
    exit 0  
fi
# otherwise we go for another round with the failing tests
 
# we keep a copy of the first log file
cp report/log.html  report/first_run_log.html
 
# we launch the tests that failed
echo
echo "#######################################"
echo "# Running again the tests that failed #"
echo "#######################################"
echo
pybot --outputdir report --rerunfailed report/output.xml --output rerun.xml $@
# Robot Framework generates file rerun.xml

if [ $? -ne 0 ]; then
    RES=true
fi
 
# we keep a copy of the second log file
cp report/log.html  report/second_run_log.html
 
# Merging output files
echo
echo "########################"
echo "# Merging output files #"
echo "########################"
echo
rebot --nostatusrc --outputdir report --output output.xml --merge report/output.xml  report/rerun.xml
# Robot Framework generates a new output.xml

if [ $RES ]; then
    exit 1
fi
