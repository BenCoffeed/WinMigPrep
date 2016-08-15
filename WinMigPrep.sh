#Name: WinMigPrep.sh
#Version: 5.0
#Original built off of script from Kevin Griffis, Concept Technology, Inc.
#Updated by Ben Tennant, Concept Technology, Inc.
#			 E:helpdesk@concepttechnologyinc.com
#			 P:(615)321-6428
#Recursively removes illegal characters from directory and file names

#Variables
read -p "What folder would you like to check for illegal Windows characters? " dir
read -p "Where would you like us to save logs? Example: /Users/btennant/Desktop/WinMigPrepLog.txt " logfile
#dir="/Users/btennant/ConceptCloud/Scripts/WinMigPrep/TESTDIR" #Change this value to the root directory where you want to change file names.
#logfile="/Users/btennant/ConceptCloud/Scripts/WinMigPrep/WinMigPrepLog.txt" #Change this value to reflect the location of your log file
declare -i n #create integer
n=0
declare -i k 
k=0

#functions
#Fucntion: contains(string,substring)
#Inputs string, substring
#Purpose: Compares string to see if string contains substring.
#Returns: integer. 1 if substring is found in string, 0 if not found.
contains() { 
	string="$1"
	substring="$2"
	if test "${string#*$substring}" != "$string"
	then
		return 0 # substring exists in string
	else
		return 1 # substring not found in string
	fi
}
removeillegals() {
	workingdir="$1"
	echo "Directory being checked:" $workingdir >> $logfile 
	items=( `ls "$workingdir" | egrep '[\<\>\:\/\\\|\?\*].+'` )
	for (( j=${#items[@]}-1 ; j>=0 ; j-- )) ; do
			echo "Illegal characters found. Attempting to correct." >> $logfile
			item="${items[j]}"
			new=`echo $item | sed 's/[<>:/\|?*]/_/g'`
			mv "$workingdir/""$item" "$workingdir/$new"
			echo "Issue corrected. Measures taken:" >> $logfile 
			echo $workingdir/$item "was renamed to" $workingdir/$new >> $logfile
			echo "" >> $logfile
	done
	echo "" >> $logfile
}
#Code
echo "#######################################################################" > $logfile
echo "#WinMigPrep start time: " `date` "                  #" >> $logfile                                #Creates new log file and denotes start time
echo "#######################################################################" >> $logfile
echo "" >> $logfile

DirArray=( `find $dir -type d` ) #creates recursive array of directories
for ((  idx=${#DirArray[@]}-1 ; idx>=0  ; idx-- )) ; do #Steps through array in reverse order. This ensures that the deepest files are renamed first. 
	
	h="${DirArray[idx]}" #Current entry
	if contains "$h" "$dir" #If current entry contains the working directory listed, then path is complete.
        then
		echo "Array index: " $idx >> $logfile
		echo "Directory:" "$h" >> $logfile 
		echo "No issue found with directory path." >> $logfile
		echo "Checking for illegal characters..." >> $logfile
		removeillegals "$h"
	else  #
		echo "Array index: " $idx >> $logfile
		echo "Directory:" "$h" >> $logfile
                echo "Space in directory path caused multiple array entries. Attempting to repair... " >> $logfile
		n=$idx-1 #Move to previous entry in array
		echo "Previous entry:" ${DirArray[n]} >> $logfile
		g="${DirArray[n]} $h"
                DirArray[n]=$g #concatenate two entries in array to get full path with space
		echo "Entry updated." >> $logfile
		echo "Updaetd Index: " $n >> $logfile
		echo "Updated Entry:" "${DirArray[n]}" >> $logfile
		echo "" >> $logfile
        fi

done                   

echo "" >> $logfile
echo "#####################################################################" >> $logfile
echo "#WinMigPrep completed: " `date` "                 #" >> $logfile
echo "#####################################################################" >> $logfile

