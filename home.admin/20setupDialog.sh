#!/bin/bash
_temp="./download/dialog.$$"

## get basic info
source /home/admin/raspiblitz.info 2>/dev/null

###################
# ENTER NAME
###################

# welcome and ask for name of RaspiBlitz 
result=""
while [ ${#result} -eq 0 ]
  do
    l1="Please enter the name of your new RaspiBlitz:\n"
    l2="one word, keep characters basic & not too long"
    dialog --backtitle "RaspiBlitz - Setup (${network}/${chain})" --inputbox "$l1$l2" 11 52 2>$_temp
    result=$( cat $_temp | tr -dc '[:alnum:]-.' | tr -d ' ' )
    shred $_temp
  done

# set lightning alias
sed -i "s/^alias=.*/alias=${result}/g" /home/admin/assets/lnd.${network}.conf

# store hostname for later - to be set right before the next reboot
# work around - because without a reboot the hostname seems not updates in the whole system
valueExistsInInfoFile=$(sudo cat /home/admin/raspiblitz.info | grep -c "hostname=")
if [ ${valueExistsInInfoFile} -eq 0 ]; then
  # add
  echo "hostname=${result}" >> /home/admin/raspiblitz.info
else
  # update
  sed -i "s/^hostname=.*/hostname=${result}/g" /home/admin/raspiblitz.info
fi

###################
# ENTER PASSWORDS 
###################

# show password info dialog
dialog --backtitle "RaspiBlitz - Setup (${network}/${chain})" --msgbox "RaspiBlitz uses 4 different passwords.
Referenced as password A, B, C and D.

A) Master User Password
B) Blockchain RPC Password
C) LND Wallet Password
D) LND Seed Password

Choose now 4 new passwords - all min 8 chars,
no spaces and only special characters - or .
Write them down & store them in a safe place.
" 15 52

# call set password a script
sudo /home/admin/config.scripts/blitz.setpassword.sh a

# sucess info dialog
dialog --backtitle "RaspiBlitz" --msgbox "OK - password A was set\nfor all users pi, admin, root & bitcoin" 6 52

# call set password b script
sudo /home/admin/config.scripts/blitz.setpassword.sh b

# success info dialog
dialog --backtitle "RaspiBlitz" --msgbox "OK - RPC password changed \n\nNow starting the Setup of your RaspiBlitz." 7 52
clear