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
