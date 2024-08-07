# Kerberos setup script
Hello and welcome.
I have created this script to easen the process of setting up the Kerberos server on Ubuntu environment. I have set some goals:
  1. Initialize the realm.
  2. Edit on the /etc/hosts file, and on /etc/kerb5.conf file. May add the option to install a DNS and edit on it instead of the /etc/hosts file.
  3. Add principals.
  4. Add services, create a keytab, and store it safely.
  5. For certail services, the script will take care of the service's configuration files. I will start wilth Apache2, then add services as I experiment (the scalability will take a long while)

I may add feature to edit on the ACL to help create a MLS system. I don't plan on doing so anytime soon.
