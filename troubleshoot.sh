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
	     echo "   3) Fix Nginx Issue"
	     echo "   4) Exit"
 
      until [[ ${MENU_OPTION} =~ ^[1-4]$ ]]; do
		read -rp "Select an option [1-4]: " MENU_OPTION
	done
	    case "${MENU_OPTION}" in
	      1)
		      clearBlockchain
		      ;;
	      2)
		      portForwarder
		      ;;
	      3)
		      nginx
		      ;;
	      4)
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

	function portForwarder() {
		
		sudo /home/pi/hnt/paket/paket/packet_forwarder/lora_pkt_fwd
		echo "Did you get an error?"
		echo ""
		echo "	1) Yes"
		echo "	2) No"
		echo "	3) Exit"
		
		until [[ ${MENU_OPTION} =~ ^[1-2]$ ]]; do
		read -rp "Select an option [1-2]: " MENU_OPTION
			
		done
	 	case "${MENU_OPTION}" in
	      		1)
		      		portForwarderProblem
		     		;;
	     		 2)
		     		exit 0
		     		;;
	      
	      		esac
		
		
		echo "Now I copy the original global_conf file to global_conf.json.bk.original"
		echo ""
		pushd /home/pi/hnt/paket/paket/packet_forwarder/
		sudo cp global_conf.json.bk.original global_conf.json
		wget http://pisces-firmware.sidcloud.cn/PacketForward/Config/V2/EU868.sh -O - | sudo bash
		sudo ./lora_pkt_fwd start
		
		#I need to make this different
		cd /home/pi/hnt/paket/paket/packet_forwarder/
		sudo ./lora_pkt_fwd start
		
	
	}
	
	function portForwarderProblem() {
	
	}
	
	
	function nginx() {
	
	
	}

#Check for full Disk
df -h 
	echo "If your Disk Usage is below 100% you´re good to go!"
	echo ""
	echo "Just leave the device online"
	echo "If not run this script again and choose: Clear Blockchain Data and resync"
