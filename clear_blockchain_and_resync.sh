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
