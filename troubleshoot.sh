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
