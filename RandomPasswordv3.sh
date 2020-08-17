#!/bin/bash


	###############################################################
	#	Copyright (c) 2018, D8 Services Ltd.  All rights reserved.  
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
	

# Username to randomise the password Customise the following but ensure the saltKey and 
# phraseKey are copied to the EA script
userName="test"
fullName="IT Support"
home="/var/${userName}"
# Reset the Password when it is Over xx days old
passWDPolicy="14"
#EncryptedPasswordFile
prefFile="/var/db/.encryptedD8.plist"

# Do not edit below this line
saltKey="${4}"
phraseKey="${5}"
#saltKey="063f7f8eb687cde2"
#phraseKey="7d7353d9547a8af1bf81d1be"

if [[ -z "${saltKey}" || -z "${phraseKey}" ]];then
	echo "Keys Missing, exiting."
	exit 1
fi

function GenerateEncryptedString() {
# Usage ~$ GenerateEncryptedString "String"
echo "${1}" | openssl enc -aes256 -a -A -S "${saltKey}" -k "${phraseKey}"
}

if id "$userName" >/dev/null 2>&1; then
	echo "Notice: User exists, continuing"
	passwordDateTime=$( dscl . read /Users/${userName} accountPolicyData | sed 1,2d | /usr/bin/xpath "/plist/dict/real[preceding-sibling::key='passwordLastSetTime'][1]/text()" 2> /dev/null | sed -e 's/\.[0-9]*//g' )
	echo "testUser is $passwordDateTime"
now_date=$(date +%s)
passwordAgeDays=$(( ($now_date - $passwordDateTime) / 86400 ))
	echo "The User ${userName} password in Days is $passwordAgeDays"
	
	if [[ "$passwordAgeDays" -gt ${passWDPolicy} ]]; then
		newPass=`cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9!@#*' | fold -w 32 | head -n 1`
        sysadminctl -deleteUser ${userName}
        sysadminctl -addUser ${userName} -fullName "${fullName}" -UID 500 -password ${newPass} -home ${home} -admin
		createhomedir -c 2>&1
		dscl . -authonly ${userName} "${newPass}"
		if [[ $? ]];then
			echo "Successful Creation of account with new Password."
			encryptedString=$(GenerateEncryptedString "${newPass}")
			defaults write "${prefFile}" pkey "${encryptedString}"
			echo "The encrypted ${userName} users password is ${newPass}"
			echo "The User ${userName} Password Age (EPOCH) is $passwordDateTime"
			echo "Encrypted Sting: ${encryptedString}"
		else
			echo "FAILED Creation of account with new Password."
		fi
	fi
fi
