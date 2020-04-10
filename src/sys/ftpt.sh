## -----------------------------------------------------------------------------
## Linux Scripts.
## FTP functions with timeout
##
## @package ojullien\bash\sys
## @license MIT <https://github.com/ojullien/bash-sys/blob/master/LICENSE>
## -----------------------------------------------------------------------------

# Copies files over using FTP. Show all responses from the remote server, as well as report on data transfer statistics.
# @param    $1 = FTP Host
#           $2 = FTP User
#           $3 = FTP User password
#           $4 = Source file name
#           $5 = destination directory
#           $6 = local directory
#           $7 = ftp error file
#           $8 = log file
FTP::verbosePut() {

    # Parameters
    if (($# != 8)) || [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]] || [[ -z "$4" ]] || [[ -z "$5" ]] || [[ -z "$6" ]] || [[ -z "$7" ]] || [[ -z "$8" ]]; then
        String::error "Usage: FTP::put <FTP Host> <FTP User> <FTP User password> <Source file name> <destination directory> <local directory> <ftp error file> <log file>"
        return 1
    fi

    # Init
    local sHost="$1" sUser="$2" sPass="$3" sFile="$4" sDestDir="$5" sLocalDir="$6" sErrorFile="$7" sLogFile="$8"
    local -i iReturn=1 iWordCount=0

    # Do the job
    timeout 30 ftp -vpin "${sHost}" <<END_SCRIPT >> "${sLogFile}" 2> "${sErrorFile}"
quote USER ${sUser}
quote PASS ${sPass}
binary
cd ${sDestDir}
lcd ${sLocalDir}
put ${sFile}
close
quit
END_SCRIPT
iReturn=$?

    # Check error
    # If the command times out, it exit with status 124.
    if ((!iReturn)); then
        iWordCount=$(wc --bytes < ${sErrorFile})
        if ((iWordCount)); then
            iReturn=1
        else
            iReturn=0
        fi
    fi

    return ${iReturn}
}

# Copies files over using FTP.
# @param    $1 = FTP Host
#           $2 = FTP User
#           $3 = FTP User password
#           $4 = Source file name
#           $5 = destination directory
#           $6 = local directory
#           $7 = ftp error file
FTP::put() {

    # Parameters
    if (($# != 7)) || [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]] || [[ -z "$4" ]] || [[ -z "$5" ]] || [[ -z "$6" ]] || [[ -z "$7" ]]; then
        String::error "Usage: FTP::put <FTP Host> <FTP User> <FTP User password> <Source file name> <destination directory> <local directory> <ftp error file>"
        return 1
    fi

    # Init
    local sHost="$1" sUser="$2" sPass="$3" sFile="$4" sDestDir="$5" sLocalDir="$6" sErrorFile="$7"
    local -i iReturn=1 iWordCount=0

    # Do the job
    timeout 30 ftp -pin "${sHost}" <<END_SCRIPT 2> "${sErrorFile}"
quote USER ${sUser}
quote PASS ${sPass}
binary
cd ${sDestDir}
lcd ${sLocalDir}
put ${sFile}
close
quit
END_SCRIPT
iReturn=$?

    # Check error
    # If the command times out, it exit with status 124.
    if ((!iReturn)); then
        iWordCount=$(wc --bytes < ${sErrorFile})
        if ((iWordCount)); then
            iReturn=1
        else
            iReturn=0
        fi
    fi

    return ${iReturn}
}
