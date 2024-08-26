# Kerberos setup script
Hello and welcome.\
#### Note
I shall revise this project.\
## Description
These two scripts shall easen the process of setting up the Kerberos server on Ubuntu environment.\
	The two scripts will not touch the encryption, you'll have to adjust it yourself. They also don't touch the ACL. I shall return to this project in the future and add these two features; with an eye towards the creation of MLS systems.\
	Excluding the inital realm creation (that is done in the installation phase), and what the program does not feature, you dont have to do anything manually.
	The two scripts do the following.\
	1. Initialize the realm.\
	2. Edit on the /etc/hosts file, and on /etc/kerb5.conf file. May add the option to install a DNS and edit on it instead of the /etc/hosts file.\
	3. Add principals.\
	4. Add services, create a keytab, and store it safely.\
	5. For certail services, the script will take care of the service's configuration files. I will start wilth Apache2, then add services as I experiment (the scalability will take a long while)\

## How to Use
	You only need to run `kerberos_set_up.sh`. It will guide you through the set up, and prompt you for some input.\

## Feedback
	I would love to hear your feedback, regarding the program's features, or the code itself if it can be optimized. My email is `ouka.lotfi@gmail.com` if you want to send it via email.\
