!bin/bash 
# Ubuntu Domain Join

# Note: This ill reuire further testing as it is not expected to work in Ubuntu 18.04. but may in Ubuntu 18.04.4 
# and is expected to work in 20.04. All must be run under sudo.

# Perform normal update/upgrade to ensure everything is the most current
apt update
apt upgrade

# Install prerequesite packages
apt install sssd heimdal-clients msktutil

# Backup default keychain and create new
mv /etc/krb5.conf /etc/krb5.conf.default
touch /etc/krb5.conf
echo "[libdefaults]" >> /etc/krb5.conf
echo "default_realm = DFDEV.JNJ.COM" >> /etc/krb5.conf
echo "rnds = no" >> /etc/krb5.conf
echo "dns_lookup_kdc = true" >> /etc/krb5.conf
echo "dns_lookup_realm = true" >> /etc/krb5.conf
echo "" >> /etc/krb5.conf
echo "[realms]" >> /etc/krb5.conf
echo "DEFDEV.JNJ.COM = {" >> /etc/krb5.conf
echo "kdc = server.dfdev.jnj.com" >> /etc/krb5.conf
echo "admin_server = server.dfdev.jnj.com" >> /etc/krb5.conf
echo "}" >> /etc/krb5.conf

# Initialize Kerberos and generate keytab file
kinit sa-dfdev-admin
klist
msktutil -N -c -b 'CN=Linux Workstations' -s WL3YGG8/wl3ygg8.dfdev.jnj.com -k my-keytab.keytab --computer-name WL3YGG8 --upn WL3YGG8$ --server server.jnj.com --user-creds-only
msktutil -N -c -b 'CN=Linux Workstations' -s WL3YGG8/wl3ygg8 -k my-keytab.keytab --computer-name WL3YGG8 --upn WL3YGG8$ --server server.dfdev.jnj.com --user-creds-only
kdestroy

# Configure SSSD
mv my-keytab.keytab /etc/sssd/my-keytab.keytab
touch /etc/sssd/sssd.conf
echo "[sssd]" >> /etc/sssd/sssd.conf
echo "services = nss, pam" >> /etc/sssd/sssd.conf
echo "config_file_version = 2" >> /etc/sssd/sssd.conf
echo "domains = dfdev.jnj.com" >> /etc/sssd/sssd.conf
echo "" >> /etc/sssd/sssd.conf
echo "[nss]" >> /etc/sssd/sssd.conf
echo "entry_negative_timeout = 0" >> /etc/sssd/sssd.conf
echo "#debug_level = 5" >> /etc/sssd/sssd.conf
echo "" >> /etc/sssd/sssd.conf
echo "[pam]" >> /etc/sssd/sssd.conf
echo "#debug_level = 5" >> /etc/sssd/sssd.conf
echo "" >> /etc/sssd/sssd.conf
echo "[domain/dfdev.jnj.com]" >> /etc/sssd/sssd.conf
echo "#debug_level = 10" >> /etc/sssd/sssd.conf
echo "enumerate = false" >> /etc/sssd/sssd.conf
echo "id_provider = ad" >> /etc/sssd/sssd.conf
echo "auth_provider = ad" >> /etc/sssd/sssd.conf
echo "chpass_provider = ad" >> /etc/sssd/sssd.conf
echo "access_provider = ad" >> /etc/sssd/sssd.conf
echo "dyndns_update = false" >> /etc/sssd/sssd.conf
echo "ad_hostname = wl3ygg8.dfdev.jnj.com" >> /etc/sssd/sssd.conf
echo "ad_server = server.dfdev.jnj.com" >> /etc/sssd/sssd.conf
echo "ad_domain = dfdev.jnj.com" >> /etc/sssd/sssd.conf
echo "ldap_schema = ad" >> /etc/sssd/sssd.conf
echo "ldap_id_mapping = true" >> /etc/sssd/sssd.conf
echo "fallback_homedir = /home/%u" >> /etc/sssd/sssd.conf
echo "default_shell = /bin/bash" >> /etc/sssd/sssd.conf
echo "ldap_sasl_mech = gssapi" >> /etc/sssd/sssd.conf
echo "ldap_sasl_authid = WL3YGG8$" >> /etc/sssd/sssd.conf
echo "krb5_keytab = /etc/sssd/my-keytab.keytab" >> /etc/sssd/sssd.conf
echo "ldap_krb5_init_creds = true" >> /etc/sssd/sssd.conf 

# Change permissions on SSSD.conf
chmod 0600 /etc/sssd/sssd.conf

# Configure PAM
# sudo nano /etc/pam.d/common-session
# Add this line after: session required pam_unix.so
# session required pam_mkhomedir.so skel=/etc/skel umask=0077
sed '/^pam_unix.so=.*/a session required pam_mkhomedir.so skel=/etc/skel umask=0077' /etc/pam.d/common-session

# Restart SSSD
systemctl restart sssd

#Add the domain admin to the local admin group - probably want to add WS_Admins group instead
# sudo adduser dfdevadmin sudo
cp /etc/sudoers /etc/sudoers.default > /dev/null
echo "dfdev.jnj.com\ws_admins ALL=(ALL)ALL" >> /etc/sudoers

