#!/bin/bash
#
#
#

option="${1}"

error(){
	[ ! -z "${1}" ] && printf "\033[31m${1}\033[0m\n" || printf "Unknown Error Occurred!\n"
	}

compatibility_test(){
	quiet=$1
	_memsz=$(cat  /proc/meminfo | grep "MemTotal" | awk '{print $2}')
	if [ $_memsz -gt 2000000 ];
	then
		case $quiet in
			-q|-quiet|--quiet-test);;
			*) printf "\033[32mMachine is compatible.\033[0m\n";;
		esac
	else
		error "Machine is not compatible! (memory less than 2GB)"
		exit 1
	fi
	}

create_swapfile(){
	# Ensure no swapfile exists.
	if [ -z "$(free -m | egrep -i 'swap')" ];
	then
		if [ ! -e "/swapfile" ];
		then
			dd if=/dev/zero of=/swapfile1 bs=1024M count=2
		fi
		# requirement for unintended reading.
		chown root:root /swapfile1
		# prevents memory reading
		chmod 0600 /swapfile1
		mkswap /swapfile1
		swapon /swapfile1
		if [  -z "$(egrep 'swapfile1' /etc/fstab)" ];
		then
			printf "/swapfile1 none swap sw 0 0\n" >> /etc/fstab
		fi
		free -m
	else
		printf "Swapfile already created.\n"
	fi
	}

help_menu(){
	printf "Setup Prerequisites\n"
	printf "Create swapfile\t\t[ -swap, -swapfile, --swapfile ]\n"
	printf "Compatibility test\t[ -test, --test ]\n"
	}

case $option in
	-swap|-swapfile) compatibility_test --quiet-test && create_swapfile;;
	-test|--test) compatibility_test;;
	-h|-help|--help) help_menu;;
	*) error "Missing or invalid parameter was given!"
esac
