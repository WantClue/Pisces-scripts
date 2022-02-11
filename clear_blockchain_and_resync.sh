sudo docker stop miner
wait 100
rm -rf /home/pi/hnt/miner/blockchain.db

rm -rf /home/pi/hnt/miner/ledger.db


pushd /home/admin
sudo wget https://raw.githubusercontent.com/briffy/PiscesQoLDashboard/main/install.sh -O - | sudo bash
