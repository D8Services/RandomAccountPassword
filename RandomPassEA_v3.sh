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
	#
	###############################################################
	#
prefFile="/var/db/.encryptedD8.plist"
saltKey="063f7f8eb687cde2"
phraseKey="7d7353d9547a8af1bf81d1be"

if [[ ! -e ${prefFile} ]];then
	echo "missing prefFile, exiting."
	exit 0
fi

## Function Decrypt Strings
function DecryptString() {
	# Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "$saltKey" -k "$phraseKey"

}


encryptedPass=$(defaults read "${prefFile}" pkey)
newPass=$(DecryptString "${encryptedPass}")
#newPass=$(echo "${encryptedPass}" | /usr/bin/openssl enc -aes256 -d -a -A -S "$saltKey" -k "$phraseKey")

echo "<result>${newPass}</result>"