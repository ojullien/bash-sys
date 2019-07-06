#!/bin/bash
## -----------------------------------------------------------------------------
## Linux Scripts.
## Install the bash-sys project into the /opt/oju/bash directory.
##
## @package ojullien\bash\scripts
## @license MIT <https://github.com/ojullien/bash-sys/blob/master/LICENSE>
## -----------------------------------------------------------------------------
#set -o errexit
set -o nounset
set -o pipefail

## -----------------------------------------------------------------------------
## Shell scripts directory, eg: /opt/Shell/scripts/
## -----------------------------------------------------------------------------
readonly m_DIR_REALPATH="$(realpath "$(dirname "$0")")"

## -----------------------------------------------------------------------------
## Defines current date
## -----------------------------------------------------------------------------
readonly m_DATE="$(date +"%Y%m%d")_$(date +"%H%M")"

## -----------------------------------------------------------------------------
## Defines main directories
## -----------------------------------------------------------------------------

# DESTINATION
readonly m_INSTALL_DESTINATION_PROJECT_NAME="bash"
readonly m_INSTALL_DESTINATION_DIR="/opt/oju"
readonly m_DIR_APP="${m_INSTALL_DESTINATION_DIR}/${m_INSTALL_DESTINATION_PROJECT_NAME}/app" # Directory holds apps
readonly m_DIR_BIN="${m_INSTALL_DESTINATION_DIR}/${m_INSTALL_DESTINATION_PROJECT_NAME}/bin" # Directory holds app entry point
readonly m_DIR_LOG="${m_INSTALL_DESTINATION_DIR}/${m_INSTALL_DESTINATION_PROJECT_NAME}/log" # Directory holds log files
readonly m_INSTALL_DESTINATION_DIR_SYS="${m_INSTALL_DESTINATION_DIR}/${m_INSTALL_DESTINATION_PROJECT_NAME}/sys" # Directory holds system files

# SOURCE
readonly m_INSTALL_APP_NAME="sys"
readonly m_DIR_SYS="$(realpath "${m_DIR_REALPATH}/../src/${m_INSTALL_APP_NAME}")"

## -----------------------------------------------------------------------------
## Defines main files
## Log file cannot be in /var/log 'cause few apps clean this directory
## -----------------------------------------------------------------------------
readonly m_LOGDIR="$(realpath "${m_DIR_REALPATH}/../src/log")"
readonly m_LOGFILE="${m_LOGDIR}/${m_DATE}_$(basename "$0").log"

## -----------------------------------------------------------------------------
## Defines colors
## -----------------------------------------------------------------------------
readonly COLORRED="$(tput -Txterm setaf 1)"
readonly COLORGREEN="$(tput -Txterm setaf 2)"
readonly COLORRESET="$(tput -Txterm sgr0)"

## -----------------------------------------------------------------------------
## Functions
## -----------------------------------------------------------------------------
Constant::trace() {
    String::separateLine
    String::notice "Main configuration"
    FileSystem::checkDir "\tSource directory:\t\t${m_DIR_SYS}" "${m_DIR_SYS}"
    FileSystem::checkDir "\tDestination app directory:\t\t\t${m_DIR_APP}" "${m_DIR_APP}"
    FileSystem::checkDir "\tDestination bin directory:\t\t\t${m_DIR_BIN}" "${m_DIR_BIN}"
    FileSystem::checkDir "\tDestination log directory:\t\t\t${m_DIR_LOG}" "${m_DIR_LOG}"
    FileSystem::checkDir "\tDestination sys directory:\t\t\t${m_INSTALL_DESTINATION_DIR_SYS}" "${m_INSTALL_DESTINATION_DIR_SYS}"
    FileSystem::checkFile "\tLog file is:\t\t\t${m_LOGFILE}" "${m_LOGFILE}"
    return 0
}

## -----------------------------------------------------------------------------
## Includes sources & configuration
## -----------------------------------------------------------------------------
# shellcheck source=/dev/null
. "${m_DIR_SYS}/runasroot.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/string.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/filesystem.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/option.sh"
# shellcheck source=/dev/null
. "${m_DIR_SYS}/config.sh"

## -----------------------------------------------------------------------------
## Help
## -----------------------------------------------------------------------------
((m_OPTION_SHOWHELP)) && Option::showHelp && exit 0

## -----------------------------------------------------------------------------
## creates destination
## -----------------------------------------------------------------------------
mkdir --parents "${m_DIR_APP}" "${m_DIR_BIN}" "${m_DIR_LOG}"\
&& chmod -R u=rwx,g=rx,o=rx "${m_INSTALL_DESTINATION_DIR}"\
&& chmod u=rwx,g=rwx,o=rwx "${m_DIR_LOG}"

## -----------------------------------------------------------------------------
## Trace
## -----------------------------------------------------------------------------
Constant::trace
Console::waitUser

## -----------------------------------------------------------------------------
## Start
## -----------------------------------------------------------------------------
String::separateLine
String::notice "Today is: $(date -R)"
String::notice "The PID for $(basename "$0") process is: $$"
Console::waitUser

FileSystem::removeDirectory "${m_INSTALL_DESTINATION_DIR_SYS}"
iReturn=$?
((0!=iReturn)) && exit ${iReturn}

FileSystem::copyFile "${m_DIR_SYS}" "${m_INSTALL_DESTINATION_DIR}/${m_INSTALL_DESTINATION_PROJECT_NAME}"
iReturn=$?
((0!=iReturn)) && exit ${iReturn}

String::notice -n "Change owner:"
chown -R root:root "${m_INSTALL_DESTINATION_DIR_SYS}"
iReturn=$?
String::checkReturnValueForTruthiness ${iReturn}
((0!=iReturn)) && exit ${iReturn}

String::notice -n "Change directories access rights:"
find "${m_INSTALL_DESTINATION_DIR_SYS}" -type d -exec chmod u=rwx,g=rx,o=rx {} \;
iReturn=$?
String::checkReturnValueForTruthiness ${iReturn}
((0!=iReturn)) && exit ${iReturn}

String::notice -n "Change files access rights:"
find "${m_INSTALL_DESTINATION_DIR_SYS}" -type f -exec chmod u=rw,g=r,o=r {} \;
iReturn=$?
String::checkReturnValueForTruthiness ${iReturn}
((0!=iReturn)) && exit ${iReturn}

## -----------------------------------------------------------------------------
## END
## -----------------------------------------------------------------------------
String::notice "Now is: $(date -R)"
exit ${iReturn}
