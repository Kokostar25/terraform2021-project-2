
#! /bin/bash
sudo apt-get update
sudo apt-get install -y
sudo service apache2 status
sudo service apache2 start
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html	                	        
	
