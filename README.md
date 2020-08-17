# RandomAccountPassword

Random Account Password creates a Coffee Machine...

Not Really. The idea of this script is to have one Extension attribute (RandomPassEA_v3.sh) which will decrypt a password on the local Mac. This is then stored in the Jamf Pro Server against the relevant Mac. While the RandomPasswordv3.sh will create the password, set the user password, encrypt it and store it in a file on the computer.

CAUTION
This workflow will delete the user in its entirity, meaning the user managed will have their entire home directory erased. 
YOU HAVE BEEN WARNED!

## Variables

userName="test"           - Username to test for
fullName="IT Support"     - Full UserName to test for
home="/var/${userName}"   - Home directory for the user
passWDPolicy="10"         - Number of days to check the password against and change if the Mac password is older.

prefFile="/var/db/.encryptedD8.plist" - Plist location of file with encrypted password stored
saltKey="${4}"            - Parameter 4 from Jamf with Salted key
phraseKey="${5}"          - Parameter 5 from Jamf with Passcode Key

## Salted Keys
You may see above the salted key and phrase key. These two items are returned from running the following commands on a Mac;

saltKey
```openssl rand -hex 8```
phraseKey
```openssl rand -hex 12```

## Scripts
RandomPassEA_v3.sh
Extension Attribute added to your Jamf PRO server, this will be populated during the inventory update process.

RandomPasswordv3.sh
The main script is RandomPasswordv3.sh, this script will check for a local account name (set to "test" within the script), if found the script will check the password expiry and compare it to the variable passWDPolicy (set to 10 currently. Alter this as you see fit.

In order to secure the Password, we are encrypting the password with a random key, this should be site specific, i.e. do this yourself!

