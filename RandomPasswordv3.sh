#!/bin/bash

	###############################################################
	#	Copyright (c) 2020, D8 Services Ltd.  All rights reserved.  
	#											
	#	
	#	THIS SOFTWARE IS PROVIDED BY D8 SERVICES LTD. "AS IS" AND ANY
	#	EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	#	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	#	DISCLAIMED. IN NO EVENT SHALL D8 SERVICES LTD. BE LIABLE FOR ANY
	#	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	#	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	#	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	#	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	#	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	#	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	#
	# written by Tomos @ D8 Services Ltd Syd / HKG
	# https://github.com/D8Services/RandomAccountPassword
	###############################################################
	#
	# cat Command brutally and braisenly stolen/utilised from the following chat on Github
	# https://gist.github.com/earthgecko/3089509
	# password expiry stolen from
	# https://www.jamf.com/jamf-nation/discussions/9559
	# branched from https://github.com/D8Services/RandomAccountPassword to randomise the
	# password leveraging the encrypted password on the computer
	
	# Initially created by Tomos Tyler 17 Aug 3030
	# Updated - Tomos Tyler 21 Aug 2020
	#  -Altered Script to decrypt Password and re-randomise the password
	
# Parameter 4 = Salt Keys Required for encyption of userCredentials
# Parameter 5 = Phrase Keys Required for encyption of userCredentials
# Parameter 6 = IT User account to manage the password


# Username to randomise the password Customise the following but ensure the saltKey and 
# phraseKey are copied to the EA script
userName="${6}"
# Reset the Password when it is Over xx days old
passWDPolicy="14"
#EncryptedPasswordFile
prefFile="/var/db/.encryptedD8.plist"

# Do not edit below this line
saltKey="${4}"
phraseKey="${5}"

# Example Keys
#saltKey="063f7fccb687cde2"
#phraseKey="7d7353cc547a8af1bf81d1be"

# Check for Keys
if [[ -z "${saltKey}" || -z "${phraseKey}" ]];then
	echo "Keys Missing, exiting."
	exit 1
fi

# Check for the Preference File
if [[ ! -f "${prefFile}" ]];then
	echo "Preference File Missing."
	exit 1
fi

## Function Encrypt String
GenerateEncryptedString() {
# Usage ~$ GenerateEncryptedString "String"
echo "${1}" | openssl enc -aes256 -a -A -S "${saltKey}" -k "${phraseKey}"
}

## Function Decrypt String
DecryptString() {
    # Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${saltKey}" -k "${phraseKey}"
}


if id "$userName" >/dev/null 2>&1; then
	echo "Notice: User exists, continuing"
	passwordDateTime=$( dscl . read /Users/${userName} accountPolicyData | sed 1,2d | /usr/bin/xpath "/plist/dict/real[preceding-sibling::key='passwordLastSetTime'][1]/text()" 2> /dev/null | sed -e 's/\.[0-9]*//g' )
	if [[ -z ${passwordDateTime} ]];then
	echo "ERROR: $userName is missing 'passwordLastSetTime', exiting."
	exit 2
	fi
	now_date=$(date +%s)
	passwordAgeDays=$(( ($now_date - $passwordDateTime) / 86400 ))
	echo "The User ${userName} password in Days is $passwordAgeDays"
	
	if [[ "$passwordAgeDays" -gt ${passWDPolicy} ]]; then
		newPass=`cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9!@#*' | fold -w 32 | head -n 1`
        	encryptedOldPass=$(defaults read "${prefFile}" pkey)
            	oldPass=$(DecryptString "${encryptedOldPass}")
		sysadminctl -resetPasswordFor "${userName}" -password "${newPass}" -adminUser "${userName}" -adminPassword "${oldPass}"
		sysadminctl -newPassword ${newPass}" -oldPassword "${oldPass}"
		dscl . -authonly ${userName} "${newPass}"
		if [[ $? ]];then
			echo "Successful password Change of account \"${userName}\" with new Password."
			echo "The User ${userName} Password Age (EPOCH) is $passwordDateTime"
		else
			echo "FAILED to Reset account \"${userName}\" with a new Password."
		fi
	fi
fi
