#Kerberos setup script
Hello and welcome.
I have created this script to easen the process of setting up the Kerberos server. I have set some goals:
  1. Initialize the realm.
  2. Edit on the /etc/hosts file, and on /etc/kerb5.conf file. May add the option to install a DNS and edit on it instead of the /etc/hosts file.
  3. Add principals (is it even possible to do so using a script?), and edit ont the ACL file.
  4. Add services (is it even possible?), create a keytab, and store it safely || securely send it to the service's server.
  5. For certail services, the script will take care of the service's configuration files. I will start wilth Apache2, then add services as I experiment (the scalability will take a long while)
For now, I have acomplished goal (1) and (2) only (just half a day of work)
