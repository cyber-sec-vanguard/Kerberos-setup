#!/bin/bash

# function to inistalize the kerveros server

init_serv () {




	while : ; do
		echo "Please, choose one option"
		echo "1. Add admin"
		echo "2. Add normal user"
		echo "3. Add service"
		echo "0. Abort"
		read choice
		if [ $choice == 0 ] ; then
			return 0
		elif [ $choice == 1 ] ; then
			echo "Enter admin name"
			read name
			
			echo "enter his password"
			read -s passwd

			echo "Adding.."
			./add_principal.expect "$name" "$passwd"
		fi
	done
}

# Function to create the realm, parses two files /etc/hosts and /etc/krb5.conf and adds what needs to be added.
init () {
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



	echo "I will help you to set up the kerberos files, principals, and services. For now, no service files are automatically configured, so you have to do them manually.\nFirstly, let's download Kerberosn\nNOTE: You will be prompted to add the realm domain, the KDC server domain, and the administrative server domain. You MUST remember your input, we need it to work.\nThe realm domain will be in this format: 'EXAMPLE.COM' in uppercase. The KDC server domain will be in this format: 'krb1.example.com'. The administrative server domain can be identical to the KDC server domain name\n"

	# Download and install kerberos. If it is already installed, this will update it, or do nothing.
	#sudo apt update
	#sudo apt install krb5-{kdc,admin-server}

	# initalize the domain names
	#input
	
	# initialize admin server
	init_serv
}
main
