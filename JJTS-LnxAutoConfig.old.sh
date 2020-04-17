#!/bin/bash
#

# [Information] ------------------------------------------------------------------------------------
# Program Name: JJT Mobility Services - Linux Auto Config (JJTS-LnxAutoConfig.sh)
# Prg Version : 0.01 DEVELOPMENT / DEBUGGING ORIGINAL
# Created By  : Walt Pritz
#               Global Mobility Services | Mac@J&J
#               Johnson & Johnson Technology
#
# Created On  : 2/25/2020
# Last Update :
# Description : This program is designed to automate the build of Auris Dual-Boot Linux Desktops by
#               installin custom components and modifying configuration files.
#
#               NOTE: The input file MUST have the extension .txt in order to be recognized.
#
# Permissions : Sudo, User
#
# Requires    : JJNet Access
#
# Prg Language: Linux Bash v4.x
#
# Prg Usage   : sudo ./JJTS-LnxAutoConfig.sh [-h|-help] [ENTER]
#
# Prg Output  : 
#
#                             JJT Global Mobility Services Linux Auto Config
#                 ./JJT-LnxAutoConfig.DEBUG.sh   Version: 0.01 DEBUG   Released: 2/25/2020
#----------------------------------------------------------------------------------------------------
# Prg Notes   : None, just yet...
#
#               This program has been over-documented to promote both learning bash scripting and
#               increase supportability. Use the source Luke! ;P
#
#       ----------------------------- [ BEGIN DEBUG CODE REMOVE ] ----------------------------
# Dev Notes   : This script is development code containing extra lines for        # DEBUG CODE REMOVE
#               testing and debugging purposes only. When a new version is        # DEBUG CODE REMOVE
#               ready for relase, please perform the following:                   # DEBUG CODE REMOVE
#                   1. COPY this script to a new file (JJT-LnxAutoConfig.sh)      # DEBUG CODE REMOVE
#                   2. From the terminal run:                                     # DEBUG CODE REMOVE
#                         sed -i '' '/DEBUG CODE REMOVE/d' ./JJT-LnxAutoConfig.sh # DEBUG CODE REMOVE
#               As a result this section, and all other DEBUG CODE, will be       # DEBUG CODE REMOVE
#               removed from the file.                                            # DEBUG CODE REMOVE
#                                                                                 # DEBUG CODE REMOVE
# To Do List  : [-] General functionality for release  <---- NEEDED IMMEDIATELY   # DEBUG CODE REMOVE
# 
# Random      : None yet                                                          # DEBUG CODE REMOVE
# Mussings                                                                        # DEBUG CODE REMOVE
#                 
# Prg History : 
# 2020.02.25  : Version 0.01 - Still in dev, but it's growing on me :)
# 
#       ------------------------------ [ END DEBUG CODE REMOVE ] -----------------------------
# ------------------------------------------------------------------------------------ [Information]

# ---- [Declarations] ------------------------------------------------------------------------------
# The following variables are used in all JJT Bash programs and should be changed for each program.
# Additionally, the program version and date should be updated as required for new releases.

# Begin JJT-BashScript Standard Variables
  prgStart=$(date +%s)                                                       # Get start and end
  prgEnd=""                                                                  # date/time
  prgTitle="JJT Global Mobility Services Linux Auto Config"
  prgFile=$0
  
  prgTerm="\e[8;50;100t"                                                     # Terminal Config
  prgVer="Version: 0.01 DEBUG"                                               # Please remember to
  prgBuild="0007"                                                            # update during dev
  prgRelDate="Released: 2/25/2020"                                           # changes
  
  prgRun="" ; prgRun2="" ; prgRun3=""                                        # Used to calculate
  prgDay="" ; prgHrs="" ; prgMin="" ; prgSec=""                              # elapsed time
  prgConOut=""                                                               # Measured output
  prgConOut2=""

#       ----------------------------- [ BEGIN DEBUG CODE REMOVE ] ----------------------------
  prgDebug=TRUE           # <[=--- Enables Debugging Main & Functions             # DEBUG CODE REMOVE
  prgFunctDebug=FALSE     # <[=--- Enables Debugging for Functions Only           # DEBUG CODE REMOVE
#       ------------------------------ [ END DEBUG CODE REMOVE ] -----------------------------

# End JJT-BashScript Standard Global Variables

# The following variables contain additional data sources used by the program. All global variables
# are declared here.

  asrNumber=""
  userName=""
  configFile=""
  configKey=""
  configValue=""

# -------------- [Functions] -----------------------------------------------------------------------
# ----------------------------------------- [displayHeader] ----------------------------------------
function displayHeader() {
# This is a standard, reusable function that determines the console size, clears the screen and,
# wait for it... displays a header of the Program Name, FileName, Version and Release Date. It is
# purely cosmetic and has no bearing on the function of the program at all.

#       ----------------------------- [ BEGIN DEBUG CODE REMOVE ] ----------------------------
  local debug=FALSE                                                               # DEBUG CODE REMOVE
#       ------------------------------ [ END DEBUG CODE REMOVE ] -----------------------------
  local cols=$( tput cols )
  local titlelen=$(( ${#prgTitle} ))
  local verdatelen=$(( ${#prgFile} + ${#prgVer} + ${#prgRelDate} + 6 ))        # +6 for space offset
  local halftitlelen=$(( $titlelen / 2 ))
  local halfverdatelen=$(( $verdatelen / 2))
  local middlecol=$(( $cols / 2 ))
  eval printf %.0s- '{1..'"${COLUMNS:-$(tput cols)}"\}; echo
  middlecol=$(( ($cols / 2) - $halftitlelen ))
  tput clear
  tput bold
  tput cup 2 $middlecol
  echo $prgTitle
  middlecol=$(( ($cols / 2) - $halfverdatelen ))
  tput cup 3 $middlecol
  echo $prgFile"   "$prgVer"   "$prgRelDate                                    # Used by this line
  eval printf %.0s- '{1..'"${COLUMNS:-$(tput cols)}"\}; echo
  tput sgr0
  tput cup 6 0

#       ----------------------------- [ BEGIN DEBUG CODE REMOVE ] ----------------------------
  if [ "${prgFunctDebug}" == TRUE ] || [ $debug == TRUE ]                         # DEBUG CODE REMOVE
  then                                                                            # DEBUG CODE REMOVE
    printf "\n***** Function DEBUG: displayHeader() *****\n"                      # DEBUG CODE REMOVE
    printf "*\tProgram Title   : %s\n" "${prgTitle}"                              # DEBUG CODE REMOVE
    printf "*\tConsole Columns : %d\n" "${cols}"                                  # DEBUG CODE REMOVE
    printf "*\tTitle Length    : %d\n" "${titlelen}"                              # DEBUG CODE REMOVE
    printf "*\tVerDate Length  : %d\n" "${verdatelen}"                            # DEBUG CODE REMOVE
    printf "***** Function DEBUG: displayHeader() *****\n\n"                      # DEBUG CODE REMOVE 
  fi                                                                              # DEBUG CODE REMOVE
#       ------------------------------ [ END DEBUG CODE REMOVE ] -----------------------------
}
# ------------------------------------------- [config_set] ------------------------------------------
# https://stackoverflow.com/a/2464883
# Usage: config_set filename key value
function config_set() {
  local file=$1
  local key=$2
  local val=${@:3}

  ensureConfigFileExists "${file}"

  # create key if not exists
  if ! grep -q "^${key}=" ${file}; then
    # insert a newline just in case the file does not end with one
    printf "\n${key}=" >> ${file}
  fi

  chc "$file" "$key" "$val"
}
# ------------------------------------- [ensureConfigFileExists] ------------------------------------
function ensureConfigFileExists() {
  if [ ! -e "$1" ] ; then
    if [ -e "$1.example" ]; then
      cp "$1.example" "$1";
    else
      touch "$1"
    fi
  fi
}
# ---------------------------------------------- [chc] ----------------------------------------------
# thanks to ixz in #bash on irc.freenode.net
function chc() { gawk -v OFS== -v FS== -e 'BEGIN { ARGC = 1 } $1 == ARGV[2] { print ARGV[4] ? ARGV[4] : $1, ARGV[3]; next } 1' "$@" <"$1" >"$1.1"; mv "$1"{.1,}; }
# ------------------------------------------- [config_get] ------------------------------------------
# https://unix.stackexchange.com/a/331965/312709
# Usage: local myvar="$(config_get myvar)"
function config_get() {
    val="$(config_read_file ${CONFIG_FILE} "${1}")";
    if [ "${val}" = "__UNDEFINED__" ]; then
        val="$(config_read_file ${CONFIG_FILE}.example "${1}")";
    fi
    printf -- "%s" "${val}";
}
# --------------------------------------- [config_read_file] ----------------------------------------
function config_read_file() {
    (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=__UNDEFINED__") | head -n 1 | cut -d '=' -f 2-;
}
# ----------------------------------------- [scriptUsage] -------------------------------------------
function scriptUsage(){
  # Simple output to the screen to teach the user how to use the program. At this time this is
  # pretty much a one-off and would have to be redeigned for each and every script. Methinks
  # there must be a better way to write a programmable, reusable version...

  printf "\tThis program is designed to configure a Linux Desktop with Auris-specific apps\n"
  printf "\tand settings.\n\n"
  printf "\tNOTE: This script must be run using sudo.\n\n"

  printf "\tUSAGE: $0 [OPTIONS] [-h|-?|--help|--?]\n\n"

  printf "\tOPTIONS:\n"
  printf "\t  -h           Displays this usage help\n"
  printf "\t  -?           Displays this usage help\n\n"
  
  printf "\t  --help       Same as -h\n"
  printf "\t  --?          Same as -?\n\n"

  printf "\tEXAMPLES:\n"
  printf "\t  Run the configuration script (That's all there is!)\n"
  printf "\t    ./JJTS-LnxAutoConfig.sh \n\n"
  printf "\t  View this script's usage (You're looking at it!)\n"
  printf "\t    ./JJTS-LnxAutoConfig.sh -?\n\n"
  printf "\t    ./JJTS-LnxAutoConfig.sh --?\n\n"
  printf "\t    ./JJTS-LnxAutoConfig.sh -h\n\n"
  printf "\t    ./JJTS-LnxAutoConfig.sh --help\n\n"
  printf "\t    ./JJTS-LnxAutoConfig.sh {insert arg here as it will display help}\n\n"

  echo
  break;
}
# ------------------------------------------------------------------------[Functions] --------------

# --------- [M a i n] ------------------------------------------------------------------------------
printf $prgTerm                                                        # Set Terminal dimensions to 
#                                                                      # something more appropriate
displayHeader                                                          # Call displayHeader()
#       ----------------------------- [ BEGIN DEBUG CODE REMOVE ] ----------------------------
if [ "${prgDebug}" = "TRUE" ]                                                     # DEBUG CODE REMOVE
then                                                                              # DEBUG CODE REMOVE
  printf "Debug is ON\n"                                                            # DEBUG CODE REMOVE
  printf "This program will... do... something... AWESOME!\n"                     # DEBUG CODE REMOVE
  sleep 1s                                                                        # DEBUG CODE REMOVE
else                                                                              # DEBUG CODE REMOVE
  printf "Debug is OFF\n"                                                         # DEBUG CODE REMOVE
fi                                                                                # DEBUG CODE REMOVE
#       ------------------------------ [ END DEBUG CODE REMOVE ] -----------------------------
printf "Please enter the ASR number: "
read asrNumber

printf "Please enter your domain username: "
read userName

printf "Updating Ubuntu Linux\n"
apt update & apt upgrade -y

printf "Installing OEM Kernel\n"
apt install linux-oem-osp1 linux-firmware

printf "Installing Nvidia Drivers\n"
ubuntu-drivers autoinstall

printf "Installing Additional Packages\n"
printf "* Kerberos-User\n"
printf "* SMB/CIFS (Samba)\n"
printf "* System Security Services\n"
apt install krb5-user samba sssd

printf "Configuring /etc/hosts\n"
configFile="/etc/hosts"
configKey="127.0.1.1 "
configValue="ASR-$asrNumber_U.auris.local ASR-$asrNumber-U"
config_set configFile configKey configValue

printf "Configuring /etc/nsswitch.conf\n"
configFile="/etc/nsswitch"
configKey="passwd: "
configValue="compat systemd sss"
config_set configFile configKey configValue
configKey="group: "
configValue="compat systemd sss"
config_set configFile configKey configValue
configKey="shadow: "
configValue="compat sss"
config_set configFile configKey configValue
configKey="gshadow: "
configValue="files"
config_set configFile configKey configValue
configKey="hosts: "
configValue="files dns mdns4_minimal [NOTFOUND=return] myhostname"
config_set configFile configKey configValue
configKey="networks: "
configValue="files"
config_set configFile configKey configValue
configKey="protocols: "
configValue="db files"
config_set configFile configKey configValue
configKey="services: "
configValue="db files sss"
config_set configFile configKey configValue
configKey="ethers: "
configValue="db files"
config_set configFile configKey configValue
configKey="rpc: "
configValue="db files"
config_set configFile configKey configValue
configKey="netgroup: "
configValue="nis sss"
config_set configFile configKey configValue
configKey="sudoers: "
configValue="files sss"
config_set configFile configKey configValue

printf "Configuring /etc/krb5.conf\n"
configFile="/etc/krb5.conf"
configKey="default_realm"
configValue="AURIS.LOCAL"
config_set configFile configKey configValue
configKey="ticket_lifetime = "
configValue="24h #"
config_set configFile configKey configValue
configKey="renew_lifetime = "
configValue="7d"
config_set configFile configKey configValue
configKey="kdc_timesync = "
configValue="1"
config_set configFile configKey configValue
configKey="ccache_type = "
configValue="4"
config_set configFile configKey configValue
configKey="forwardable = "
configValue="true"
config_set configFile configKey configValue
configKey="proxiable = "
configValue="true"
config_set configFile configKey configValue
configKey="fcc-mit-ticketflags = "
configValue="true"
config_set configFile configKey configValue

printf "Configuring /etc/samba/smb.conf\n"
configFile="/etc/samba/smb.conf"
configKey="workgroup = "
configValue="AURIS"
config_set configFile configKey configValue
configKey="client signing = "
configValue="yes"
config_set configFile configKey configValue
configKey="client use spnego = "
configValue="yes"
config_set configFile configKey configValue
configKey="kerberos method = "
configValue="secrets and keytab"
config_set configFile configKey configValue
configKey="realm = "
configValue="AURIS.LOCAL"
config_set configFile configKey configValue
configKey="security = "
configValue="ads"
config_set configFile configKey configValue

printf "Configuring /etc/sssd/sssd.conf\n"
touch /etc/sssd/sssd.conf
printf "[sssd]\n"  >> /etc/sssd/sssd.conf
printf "services = nss, pam\n" >> /etc/sssd/sssd.conf
printf "config_file_version = 2\n" >> /etc/sssd/sssd.conf
printf "domains = AURIS.LOCAL\n" >> /etc/sssd/sssd.conf
printf " [domain/AURIS.LOCAL]\n" >> /etc/sssd/sssd.conf
printf "id_provider = ad\n" >> /etc/sssd/sssd.conf
printf "access_provider = ad\n" >> /etc/sssd/sssd.conf
printf "override_homedir = /home/%d/%u\n" >> /etc/sssd/sssd.conf
printf "cache_credentials = True\n" >> /etc/sssd/sssd.conf
printf "krb5_store_password_if_online = True\n" >> /etc/sssd/sssd.conf

# configFile="/etc/sssd/sssd.conf"
# configKey="services = "
# configValue="nss, pam"
# config_set configFile configKey configValue
# configKey="config_file_version = "
# configValue="2"
# config_set configFile configKey configValue
# configKey="domains = "
# configValue="AURIS.LOCAL [domain/AURIS.LOCAL]"
# config_set configFile configKey configValue
# configKey="id_provider = "
# configValue="ad"
# config_set configFile configKey configValue
# configKey="access_provider = "
# configValue="ad"
# config_set configFile configKey configValue
# configKey="override_homedir = "
# configValue="/home/%d/%u"
# config_set configFile configKey configValue
# configKey="cache_credentials = "
# configValue="True"
# config_set configFile configKey configValue
# configKey="krb5_store_password_if_offline = "
# configValue="True"
# config_set configFile configKey configValue

printf "Changing permissions of /etc/sssd/sssd.conf\n"
chmod 600 /etc/sssd/sssd.conf

printf "Joining domain...\n"
net ads join -U ${userName} -D AURIS.LOCAL

printf "Restarting sssd\n"
systemctl restart sssd

printf "Checking AD for user name (Enter password when prompted)\n"
getent username

printf "Check box to create home directory on login\n"
dpkg-reconfigure libpam-runtime

printf "Grant sudo permissions to user\n"
usermod -aG sudo username

printf "Reconfigure snap to use home dir not in /home\n"
echo @(HOMEDIRS)+=/home/AURIS.LOCAL/ > /etc/apparmor.d/tunables/home.d/my-homes 
apparmor_parser -r /var/lib/snapd/apparmor/profiles/*
echo 'mount  options=(rw  rbind)  /home/AURIS.LOCAL/  ->  /tmp/snap.rootfs_*/home/,'  > /var/lib/snapd/apparmor/snap-confine/my-homes 
apparmor_parser -r /etc/apparmor.d/*snap-confine*

printf "Configuration Complete! Please perform the following: (Will automate later)
printf "1. Login with localadmin credentials\n"
printf "2. Find the name of the Encrypted Linux partition:\n"
printf "   fdisk -l | grep Linux\n\n"
fdisk -l | grep Linux
printf "\n"
printf "3. Highlight and Copy name of bigger partition\n"
printf "4. Add user encryption key:\n"
printf "   cryptsetup luksAddKey [CTRL+SHIFT+V]\n"
printf "5. Type Admin encryption password\n"
printf "6. Have user pick an encryption password and verify, then log into system\n\n"

prgEnd=$(date +%s)                                                     # Capture the "End" date/time
prgRun=$(echo "$prgEnd - $prgStart" | bc)                              # Calc number of elapsed secs
prgDay=$(echo "$prgRun/86400" |bc)                                     # Calc number of elapsed days
prgRun2=$(echo "$prgRun-864000*$prgDay" | bc)                          # Calc remaining elapsed secs
prgHrs=$(echo "$prgRun2/3600" | bc)                                    # Calc number of elapsed hrs
prgRun3=$(echo "$prgRun2-3600*$prgHrs" | bc)                           # Calc remaining elapsed secs
prgMin=$(echo "$prgRun3/60" | bc)                                      # Calc number of elapsed mins
prgSec=$(echo "$prgRun3-60*$prgMin" | bc)                              # Calc remaining elapsed secsa

# Ouput the elapsed time to the console (We're done!... if the DEBUG flag is FALSE)
printf "Elapsed time: %d:%02d:%02d:%02d\n\n" $prgDay $prgHrs $prgMin $prgSec




# ------------------------------------------------------------------------------ [M a i n] ---------


