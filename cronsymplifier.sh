#!/bin/sh
# written by Tervor
# 20130505

#####define variables#####
# 0 = quiet
# 1 = error
# 2 = warning
# 3 = info
# 4 = debug
loglevel=4
# 0 = output
# 1 = no output
no_output=0
logfile="/var/log/cronsymplifier.log"
##########################

###define own variables###
# define the variables here which you need in your commands
# please use self_ as a prefix to be sure the variable will not be used later
# example: self_my_variable="/tmp"
# and use it with a $ in front in your commands (like in every other shell script)
# example: run_ls="ls  $self_my_variable"
self_rsync_logfile=$logfile
self_sync_src="user@mysynchost.mydomain.tld"
self_rsync_path="/usr/bin/rsync"

##########################

#####define commands######
# to add a new option just add the variable run_{name of option}="{command}"
# you need to replace the text in brackets {}
# example: run_ls="ls"
# to run multiple commands, just add && between
# to add alternative text just add the variable run_{name of option}_desc="{description}"
# example: run_ls_desc="list /tmp"
run_games="$self_rsync_path -rWhq  --delete-delay --size-only  --progress  --log-file=$self_rsync_logfile ${self_sync_src}::game /volume1/Games/ && /bin/chmod -R 777 /volume1/Games/"
run_games_desc="games sync from Host"
run_video="$self_rsync_path -rWhq  --delete-delay --size-only  --progress  --log-file=$self_rsync_logfile ${self_sync_src}::video /volume1/video/ && /bin/chmod -R 777 /volume1/video/"
run_video_desc="video sync from Host"
run_test="ls"
run_test_desc="nothing"
##########################

help() {
        echo "usage: $0 [alias of command] ..."
        return
}

log() {
        if [ $# -ge 2 ]; then
                if [ $loglevel -ge $1 ] && [ $1 -ne 0 ]; then
                        case $1 in
                                1) log_prefix="error: ";;
                                2) log_prefix="warning: ";;
                                3) log_prefix="info: ";;
                                4) log_prefix="debug: ";;
                                *) log_prefix="invalid_log_level: ";;
                        esac
                        log=`date +%b\ %d\ %T\ `$log_prefix
                        first=0
                        for y in $@; do
                                if [ $first -eq 1 ]; then
                                        log="$log $y"
                                else
                                        first=1
                                fi
                        done
                        if [ $no_output -eq 0 ]; then
                                echo $log
                        fi
                        echo $log >> $logfile
                fi
        else
                log=`date +%b\ %d\ %Ti\ `" no_log_level: $*"
                if [ $no_output -eq 0 ]; then
                        echo $log
                fi
                echo $log >> $logfile
        fi
}

if [ $# -ne 0 ]; then
        log 4 "$# arguments given ($@)"
        for i in $@; do
                eval run_command="\$run_$i"
                if [ -n "$run_command" ]; then
                        eval echo \$run_$i
                        run="$run $i"
                        log 4 "added $i"
                elif [ $i -eq "help" ]; then
                        log 4 "Help argument detected"
                        help
                        exit 0
                else
                        log 2 "invalid argument given"
                        help
                        exit 1
                fi
        done
        log 4 "The following will be executed:$run"
        for j in $run; do
                eval run_command="\$run_$j"
                eval run_command_desc="\$run_${j}_desc"
                log 3 "$run_command_desc is being executed"
                $run_command
                if [ $? -eq 0 ]; then
                        log 3 "$run_command_desc was successful"
                else
                        log 1 "$run_command_desc failed"
                        log 1 "use tail $logfile for more information"
                        exit 1
                fi
        done
        exit 0
else
        log 2 "zero arguments given"
        help
        exit 1
fi
