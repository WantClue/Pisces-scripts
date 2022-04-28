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
	     echo "   2) Fix PacketForwarder Issue"
	     echo "   3) Fix Dashboard not loading"
	     echo "   4) Get a new Snapshot"
	     echo "   5) Decrease Peerbook not found error"
	     echo "   6) Exit"
 
      until [[ ${MENU_OPTION} =~ ^[1-6]$ ]]; do
		read -rp "Select an option [1-6]: " MENU_OPTION
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
		      #Check for full Disk
			df -h 
			echo "If your Disk Usage is below 100% you´re good to go!"
			echo ""
			echo "You can ignore most of the error Logs of Dashboard"
			echo "Just leave the device online"
			echo "If not run this script again and choose: Clear Blockchain Data and resync"
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
		
		echo "By using this fix you will change some files in your Hotspot"
		echo "If you´re sure what you´re doing go ahead an choos an option"
		echo "This script uses the Pkt Fwd Fix of inigoflores!"
		echo ""
		local PS3='Please enter sub option: '
  		local options=("Fix issue" "Sub menu quit")
  		local opt
  		select opt in "${options[@]}"
  			do
      				case $opt in
          				"Sub menu item 1")
             				 	sudo wget https://raw.githubusercontent.com/inigoflores/pisces-p100-tools/main/Packet_Forwarder_V2/update.sh -O - | sudo bash
             					;;
          				"Sub menu quit")
              					return
              					;;
          				*) echo "invalid option $REPLY";;
      				esac
  			done
			
			
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
	wget https://raw.githubusercontent.com/moophlo/pisces-miner-scripts/main/clear_resync.sh -O - | sudo bash
}
	
function peerBookIncrease() {
	
		echo "Do you really want to change the Peerbook settings?"
		echo "This is testing only!!!"
		echo ""
		echo "	1) Yes"
		echo "	2) No"
		
		until [[ ${MENU_OPTION} =~ ^[1-2]$ ]]; do
		read -rp "Select an option [1-2]: " MENU_OPTION
			
		done
	 	case "${MENU_OPTION}" in
	      		1)	
		      		wget https://raw.githubusercontent.com/WantClue/Pisces-scripts/main/peerbook_fix.sh -O - | sudo bash
		     		;;
	     		 2)
		     		exit 0
		     		;;
	      
	      		esac
	
}
	

initialQuestions
manageMenu
