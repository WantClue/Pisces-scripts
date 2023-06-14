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
