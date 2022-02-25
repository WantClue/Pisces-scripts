#!/bin/bash

function isRoot() {
	if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
	fi
}

 function initialQuestions() {
        echo "Welcome to the Pisces Troubleshoot Script!"
        echo "The git repository is available at: https://github.com/WantClue/Pisces-scripts"
        echo ""
        echo ""
        echo ""
        echo ""
        read -n1 -r -p "Press any key to continue..."
        
 }
 
 function manageMenu() {
       echo "What do you want to do?"
	     echo "   1) Clear Blockchain Data and resync"
	     echo "   2) Fix PortForwarder Issue"
	     echo "   3) Fix Dashboard not loading"
	     echo "   4) Get a new Snapshot"
	     echo "   5) Decrease Peerbook not found error"
	     echo "   6) Exit"
 
      until [[ ${MENU_OPTION} =~ ^[1-4]$ ]]; do
		read -rp "Select an option [1-4]: " MENU_OPTION
	done
	    case "${MENU_OPTION}" in
	      1)
		      clearBlockchain
		      ;;
	      2)
		      packetForwarder
		      ;;
	      3)
		      nginx
		      ;;
	      4)
		      newSnapshot
		      ;;
	      5)
		      peerBookIncrease
		      ;;
	      6)
		      exit 0
		      ;;
	      esac
 
 }



	function clearBlockchain() {

		echo "Stopping the miner!!!"
		sudo docker stop miner
		sleep 2
		echo "Clearing Blockchain-Data!!!"
		sleep 2
		rm -rf /home/pi/hnt/miner/blockchain.db
		rm -rf /home/pi/hnt/miner/ledger.db
		echo "Downloading the latest Data. This will take some time leave the Miner online!!!"
		sleep 10
		pushd /home/admin
		sudo wget https://raw.githubusercontent.com/briffy/PiscesQoLDashboard/main/install.sh -O - | sudo bash
	}

	function packetForwarder() {
		
		sudo /home/pi/hnt/paket/paket/packet_forwarder/lora_pkt_fwd
		echo "If your PacketForwarder is green in Dashboard don´t run this!"
		echo "Did you get an error?"
		echo ""
		echo "	1) Yes"
		echo "	2) No"
		
		until [[ ${MENU_OPTION} =~ ^[1-2]$ ]]; do
		read -rp "Select an option [1-2]: " MENU_OPTION
			
		done
	 	case "${MENU_OPTION}" in
	      		1)
		      		packetForwarderProblem
		     		;;
	     		 2)
		     		exit 0
		     		;;
	      
	      		esac
		
		
				
	
	}
	
	function packetForwarderProblem() {
		echo "Now I copy the original global_conf file to global_conf.json.bk.original"
		echo ""
		
		pushd /home/pi/hnt/paket/paket/packet_forwarder/
		sudo cp global_conf.json.bk.original global_conf.json
		
		echo "Done!"
		echo "Now I download the tweaked file"
		
		wget https://raw.githubusercontent.com/WantClue/Pisces-scripts/main/packet_fwd_fix.json -o /home/pi/hnt/paket/paket/packet_forwarder/global_conf.json
		
		echo "Done!"
		echo "Now we can start the Packetforwarder again"		
		
		cd /home/pi/hnt/paket/paket/packet_forwarder/
		sudo ./lora_pkt_fwd start
				
		echo "Please check the Dashboard if your PaketForwarder is now running"
	}
	
	
	function nginx() {
		echo ""
		echo "Did you got the Dashboard error message:"
		echo "Bad Gateway Error 400 ?"
		echo "	1) Yes"
		echo "	2) No"
		
		until [[ ${MENU_OPTION} =~ ^[1-2]$ ]]; do
		read -rp "Select an option [1-2]: " MENU_OPTION
			
		done
	 	case "${MENU_OPTION}" in
	      		1)
		      		echo "open the Dashboard with https://yourmineripadress"
		     		;;
	     		 2)
		     		echo "You´re good nothing is wrong!"
				exit 0
		     		;;
	      
	      		esac
	
	}
	
	function newSnapshot() {
	SNAPSHOT_S=`curl --silent https://snapshots-wtf.sensecapmx.cloud/latest-snap.json|awk -F':' '{print $3}'| rev | cut -c2- | rev`
	SNAPSHOT_N=`curl --silent https://helium-snapshots.nebra.com/latest.json|awk '{print $2}'| rev | cut -c2- | rev`


	if [ $((SNAPSHOT_S)) -ge $((SNAPSHOT_N)) ]

	then

	minername=$(docker ps -a|grep miner|awk -F" " '{print $NF}')
	newheight=`curl --silent https://snapshots-wtf.sensecapmx.cloud/latest-snap.json|awk -F':' '{print $3}'| rev | cut -c2- | rev`
	echo "Snapshot height is $newheight";
	echo "Stopping the miner... "
	sudo docker stop $minername
	echo "Clearing blockchain data... "
	sudo rm -rf /home/pi/hnt/miner/blockchain.db
	sudo rm -rf /home/pi/hnt/miner/ledger.db
	echo -n "Starting the miner... "
	sudo docker start $minername
	filepath=/tmp/snap-$newheight;
	if [ ! -f "$filepath" ]; then
  		echo "Downloading latest snapshot from SenseCAP"
	  	wget -q --show-progress https://snapshots-wtf.sensecapmx.cloud/snap-$newheight -O /tmp/snap-$newheight
	else
  		modified=`stat -c %Y $filepath`
 		now=`date +%s`
 		longago=`expr $now - $modified`
 		longagominutes=`expr $longago / 60`
  		#NUM_SECS=`expr $HOW_LONG % 60`
  		echo "Up-to-date snapshot already downloaded $longagominutes minutes ago"
  		sleep 5; # Wait until the miner is fully functional
	fi
		echo -n "Pausing sync... "
		sudo docker exec $minername sh -c 'export RELX_RPC_TIMEOUT=600; miner repair sync_pause'
		echo -n "Cancelling pending sync... "
		sudo docker exec $minername sh -c 'export RELX_RPC_TIMEOUT=600;miner repair sync_cancel'
		echo "Start loading snap-$newheight at `date +%H:%M`. This can take up to 60 minutes"
		sudo rm -f /home/pi/hnt/miner/snap/snap-*
		sudo cp /tmp/snap-$newheight /home/pi/hnt/miner/snap/snap-$newheight
		> /tmp/load_result
		now=`date +%s`
		((sudo docker exec $minername sh -c "export RELX_RPC_TIMEOUT=3600; miner snapshot load /var/data/snap/snap-$newheight" > /tmp/load_result) > /dev/null 2>&1 &)
		#(((sleep 30 && echo "ok") > /tmp/load_result) > /dev/null 2>&1 &)
	while :
		do
   		 result=$(cat /tmp/load_result);
   	if [ "$result" = "ok" ]; then
       modified=`stat -c %Y /tmp/load_result`
       longago=`expr $modified - $now`
       longagominutes=`expr $longago / 60`
       echo " "
       echo "Snapshot loaded in $longagominutes minutes"
       sudo rm -f /home/pi/hnt/miner/snap/snap-$newheight
       rm /tmp/load_result
       echo -n "Resuming sync... "
       sudo docker exec $minername sh -c 'export RELX_RPC_TIMEOUT=600;miner repair sync_resume'
       echo "Done!"
       break;
    elif [ "$result" = "" ];then
       echo -n "."
    else
       echo "Error: Snapshot could not be loaded. Try again"
       break;
    fi
    sleep 120
done
	else
		minername=$(docker ps -a|grep miner|awk -F" " '{print $NF}')
		newheight=`curl --silent https://helium-snapshots.nebra.com/latest.json|awk '{print $2}'| rev | cut -c2- | rev`
		echo "Snapshot height is $newheight";
		echo "Stopping the miner... "
		sudo docker stop $minername
		echo "Clearing blockchain data... "
		sudo rm -rf /home/pi/hnt/miner/blockchain.db
		sudo rm -rf /home/pi/hnt/miner/ledger.db
		echo -n "Starting the miner... "
		sudo docker start $minername
		filepath=/tmp/snap-$newheight;
	if [ ! -f "$filepath" ]; then
  		echo "Downloading latest snapshot from Nebra"
  		wget -q --show-progress https://helium-snapshots.nebra.com/snap-$newheight -O /tmp/snap-$newheight
	else
  		modified=`stat -c %Y $filepath`
  		now=`date +%s`
  		longago=`expr $now - $modified`
  		longagominutes=`expr $longago / 60`
  		#NUM_SECS=`expr $HOW_LONG % 60`
  		echo "Up-to-date snapshot already downloaded $longagominutes minutes ago"
  		sleep 5; # Wait until the miner is fully functional
	fi
		echo -n "Pausing sync... "
		sudo docker exec $minername sh -c 'export RELX_RPC_TIMEOUT=600; miner repair sync_pause'
		echo -n "Cancelling pending sync... "
		sudo docker exec $minername sh -c 'export RELX_RPC_TIMEOUT=600;miner repair sync_cancel'
		echo "Start loading snap-$newheight at `date +%H:%M`. This can take up to 60 minutes"
		sudo rm -f /home/pi/hnt/miner/snap/snap-*
		sudo cp /tmp/snap-$newheight /home/pi/hnt/miner/snap/snap-$newheight
		> /tmp/load_result
		now=`date +%s`
		((sudo docker exec $minername sh -c "export RELX_RPC_TIMEOUT=3600; miner snapshot load /var/data/snap/snap-$newheight" > /tmp/load_result) > /dev/null 2>&1 &)
		#(((sleep 30 && echo "ok") > /tmp/load_result) > /dev/null 2>&1 &)
	while :
		do
    			result=$(cat /tmp/load_result);
    		if [ "$result" = "ok" ]; then
       			modified=`stat -c %Y /tmp/load_result`
       			longago=`expr $modified - $now`
       			longagominutes=`expr $longago / 60`
       			echo " "
       			echo "Snapshot loaded in $longagominutes minutes"
       			sudo rm -f /home/pi/hnt/miner/snap/snap-$newheight
       			rm /tmp/load_result
       			echo -n "Resuming sync... "
       			sudo docker exec $minername sh -c 'export RELX_RPC_TIMEOUT=600;miner repair sync_resume'
       			echo "Done!"
       			break;
    	elif [ "$result" = "" ];then
       		echo -n "."
    	else
       		echo "Error: Snapshot could not be loaded. Try again"
       		break;
    	fi
    	sleep 120
	done
fi
	
	}
	
	function peerBookIncrease() {
	
		echt "Do you really want to change the Peerbook settings?"
		echo "This is testing only!!!"
		echo ""
		echo "	1) Yes"
		echo "	2) No"
		
		until [[ ${MENU_OPTION} =~ ^[1-2]$ ]]; do
		read -rp "Select an option [1-2]: " MENU_OPTION
			
		done
	 	case "${MENU_OPTION}" in
	      		1)	
		      		peerBook
		     		;;
	     		 2)
		     		exit 0
		     		;;
	      
	      		esac
	
	}
	
	function peerBook() {
	echo "Now I copy your old sys.conf to the new file sys.config.old"
	echo "Then I download the updated file"
	echo "Grab a beer and enjoy the increased PeerBook"
	
	echo "download complete!"
	echo "stopping miner now"
	docker stop miner
	curl -sLf https://raw.githubusercontent.com/WantClue/Pisces-scripts/main/sys.conf.update -o /home/pi/hnt/miner/configs/sys.config
	docker start miner
	echo "Done!"
	echo -e "In order to verify that the changes are working, run every few minutes \n"
	echo -e "sudo docker exec miner miner peer book -c \n"
	}

	#Check for full Disk
	df -h 
	echo "If your Disk Usage is below 100% you´re good to go!"
	echo ""
	echo "You can ignore most of the error Logs of Dashboard"
	echo "Just leave the device online"
	echo "If not run this script again and choose: Clear Blockchain Data and resync"
