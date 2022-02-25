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
