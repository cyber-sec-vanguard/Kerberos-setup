#!/bin/bash

# function to inistalize the kerveros server

init_serv () {
	while : ; do
		echo "\n--------------------------------------------------------------------\n"
		echo "Please, choose one option"
		echo "1. Add admin"
		echo "2. Add normal user"
		echo "3. Add service"
		echo "0. Abort"
		read choice
		if [ $choice == 0 ] ; then
			exit 0
		elif [ $choice == 1 ] ; then
			echo "Enter admin name"
			read name
			
			echo "enter his password"
			read -s passwd

			echo "Adding.."
			# Let's call the Expect Script to continue the job. It will `expect` `something` from the console, and give it input based on which `expect`
			./add_princ.expect "$name" "$passwd" "" "$choice"
			
			echo "Done"
		
		elif [ $choice == 2 ] ; then
			echo "Enter admin name"
                        read name

                        echo "enter his password"
                        read -s passwd

                        echo "Adding.."
                        ./add_princ.expect "$name" "$passwd" "" "$choice"
			echo "Done"

		elif [ $choice == 3 ] ; then 
			echo "Enter service name"
			read service

			echo "enter hostname. It must be in this format <service.example.domainname.com>. Mak sure it is correct, the program will not verify its validity."
                        read hostname

			echo "Does the service reside not on this machine? (yes/no)"
			read reside
			while [[ $reside != "yes" && $reside != "no" ]] ; do
				echo "Invalid answer. Please, enter either 'yes', or 'no'. Keep it simple"
		       		read reside
			done		
			if [ $reside == "yes" ] ; then
				username=$(whoami) # To get the hostname. We need this to form the path /home/$username/...
                        	echo "Adding.."
				touch ~/service.keytab
				./add_princ.expect "$service" "" "$hostname" "$choice" "$reside" "$username"
				echo "Done. Make sure to use 'chown' and 'chmod' to set the right access controls to this file. This access must be granted for the service exlusivly, set the user to this server, and the group to this server, and give nothing for others. If this service resides on another machine, then securily transfer the file to the host destination"
			fi
		fi
		echo "If the service was Apache2 for HTTP, do you want to set it up on THIS machine? (yes/no)"
		read choice
                while [[ $choice != "yes" && $choice != "no" ]] ; do
                	echo "Invalid answer. Please, enter either 'yes', or 'no'. Keep it simple"
                       	read choice
                done
		echo "Installing dependencies.."
		sudo apt install libapache2-mod-auth-gssapi
		sudo a2enmod auth_gssapi 
		sudo a2enmod ssl
		sudo systemctl restart apache2
		echo "Done."
		echo "\n--------------------------------------------------------------------\n"
		
		echo "Configuring files.."
		# Edit the /etc/apache2/available-sites/000-default.conf file
		# Firstly: add 'ServerName webmaster@domain.com
        	sudo sed -i "/www.example.com/c\\ServerName $domain.com\n" /etc/apache2/sites-available
                
		# Do similarly to the line bellow it
		sudo sed -i "/webmaster/c\\ServerAdmin webmaster@$domain.com\n" /etc/apache2/sites-available
		
		# Look to add the new lines to configure the GSSAPI authentication mechanism
		match="/DocumentRoot /var/www/html/"
		new_lines="
		<Location />\n
		AuthType GSSAPI\n
                AuthName \"Kerberos Login\"\n
                GSSAPICredStore keytab:/home/$domain/apache2.keytab\n
                GssapiAllowedMech krb5\n
                GssapiBasicAuth on\n
                GssapiLocalName on\n
                GssapiUseSessions on\n
                #GssapiLocalName on\n
                #GssapiSSLonly on\n
                #GSSAPIAuthentication on\n
                #GSSAPILeanupCredentials on\n
                Require valid-user\n
        	</Location>\n
		"
		sudo sed -i "/$match/a\\$new_lines" /etc/apache2/sites-available
		echo "Done."
		echo "\n--------------------------------------------------------------------\n"
		echo "Restarting services.."
		# Restart service
		sudo systemctl restart apache2
		echo "Done. Test the configuration now. Note that this is as far as I can help you. Common solutions: use 'sudo chown www-data:www-data /home/$domain/apache2.keytab' and 'sudo chmod 600 /home/$domain/apache2.keytab'"
	done
}

# Function to create the realm, parses two files /etc/hosts and /etc/krb5.conf and adds what needs to be added.
init () {
	# initialize the realm
	sudo krb5_newrealm
	# Get the IP address
	ip=$(sudo journalctl -r | grep -m1 "dhcp" | grep -oP '\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b')

	# Add it in the /etc/hosts file
	echo "$ip $1" >> /etc/hosts
	echo "Added the IP address of the kerberos server to the /etc/hosts file successfully."

	# Add the realm to the krb5.conf under [domain_realm]
	sed -i "/\[domain_realm]/a      .$ip = ${1^^}\n    $ip = ${1^^}\n" /etc/krb5.conf
}

# Function to take input: Realm name, and servers name. 
input () {
	echo "Hello, let's set up your Kerberos realm\n"
	echo "Firstly, this script assumes that the time on each machine is synchronized\n"
	echo "Please, enter the realm domain name you chose previously"
	read realm_domain
	while : ; do
		if [ realm_domain =~ [A-Z0-9-_]*\.+[A-Z]{0,3}$ ] ; then
        		# Call the functions that creates the realm, edits the /etc/hosts, and /etc/krb5.conf file
			init "$realm_domain"			
			break
        	else   
                       echo "Please follow the correct format (it must be something like EXAMPLE.COM)"
			read realm_domain
		fi
	done
}
main() {
	echo "---------------------------------------------------------------------------------------------------------------\n------------------------------------Hello and Welcome to my Kerberos Script----------------------------"



	echo "I will help you to set up the kerberos files, principals, and services. For now, no service files are automatically configured, so you have to do them manually.\rFirstly, let's download Kerberosn\rNOTE: You will be prompted to add the realm domain, the KDC server domain, and the administrative server domain. You MUST remember your input, we need it to work.\rThe realm domain will be in this format: 'EXAMPLE.COM' in uppercase. The KDC server domain will be in this format: 'krb1.example.com'. The administrative server domain can be identical to the KDC server domain name\r"

	# Download and install kerberos. If it is already installed, this will update it, or do nothing.
	sudo apt update
	sudo apt install krb5-{kdc,admin-server}

	# initalize the domain names
	input
	
	# initialize admin server
	init_serv
}
main
