#! /bin/sh

help_info ()
{
	echo "****************************************************************************"
	echo "*"
	echo "* MODULE:             Linux Script - plant robot tcp process"
	echo "*"
	echo "* COMPONENT:          This script used to install or uninstall python process"
	echo "*"
	echo "* REVISION:           $Revision: 1.0 $"
	echo "*"
	echo "* DATED:              $Date: 2016-9-06 11:16:28 +0000 () $"
	echo "*"
	echo "* AUTHOR:             PCT"
	echo "*"
	echo "***************************************************************************"
	echo ""
	echo "* Copyright panchangtao@gmail.com. 2016. All rights reserved"
	echo "*"
	echo "***************************************************************************"
}

usage()
{
	echo "\033[32m ##################Usage################## \033[0m"
	echo "\033[32m Install process use: ./auto_run.sh 0 \033[0m"
	echo "\033[32m Uninstall process use: ./auto_run.sh 1 \033[0m"
}

check_tools()
{
	echo " check pip tool..."
    pip -V
    if [ $? -ne 0 ];then  # 返回值不等于0表示命令没有执行成功
		echo "\033[31m can't find pip, please install pip and try again \033[0m"  # 错误信息用红色打印
		exit 1
	else
		echo "\033[32m pip check success \033[0m"  # 成功信息用绿色打印
	fi

	echo " check pyinstaller tool..."
    pyinstaller -v
    if [ $? -ne 0 ];then
		echo " can't find pyinstaller, auto install it"
		sudo pip install pyinstaller
		echo "export PATH=$PATH:~/.local/bin" >> ~/.bashrc
		source ~/.bashrc
		echo " check pyinstaller tool again..."
		pyinstaller -v
		if [ $? -ne 0 ];then
			echo "\033[31m can't find pyinstaller, please manual install it \033[0m"
			exit 1
		fi
	fi
	echo "\033[32m check pyinstaller success \033[0m"
	
	echo " check pyzeromq..."
	pip list | grep pyzmq
	if [ $? -ne 0 ];then
		echo " can't find pyzmq, auto install it"
		sudo pip install pyzmq
		echo " check pyzeromq again..."
		pip list | grep pyzmq
		if [ $? -ne 0 ];then
			echo "\033[31m can't find pyzmq, please install it \033[0m"
			exit 1
		fi
	fi
	echo "\033[32m check pyzmq success \033[0m"

	echo " check sysv-rc-conf..."
	sysv-rc-conf --list | grep sudo
	echo $?
	if [ $? -ne 0 ];then
		echo " can't find sysv-rc-conf, auto install it"
		sudo apt-get install sysv-rc-conf
		echo " check sysv-rc-conf again..."
		sysv-rc-conf --list | grep sudo
		if [ $? -ne 0 ];then
			echo "\033[31m can't find sysv-rc-conf, please install it \033[0m"
			exit 1
		fi
	fi
	echo "\033[32m check sysv-rc-conf success \033[0m"	
}

create_bin()
{
	pyinstaller -F plant_robot_tcp.py
	if [ ! -f ./dist/plant_robot_tcp ]; then
		echo "\033[31m can't create bin file, please try again \033[0m"
		exit 1
	fi
	echo "\033[32m create plant_robot_tcp success \033[0m"
}

install()
{
	sudo cp ./dist/plant_robot_tcp /usr/bin/
	sudo cp ./plant_robot_tcp.sh /etc/init.d/
	cd /etc/init.d/; sudo sysv-rc-conf plant_robot_tcp.sh on
	echo "\033[32m install plant_robot_tcp success \033[0m"
}

uninstall()
{
	sudo /etc/init.d/plant_robot_tcp.sh stop

	if [ -f /etc/init.d/plant_robot_tcp.sh ]; then
		echo "\033[32m remove auto satrt \033[0m"
		cd /etc/init.d/; sudo sysv-rc-conf plant_robot_tcp.sh off
		sudo rm /etc/init.d/plant_robot_tcp.sh
	fi
		
	if [ -f /usr/bin/plant_robot_tcp ]; then
		echo "\033[32m delete bin \033[0m"
		sudo rm /usr/bin/plant_robot_tcp
	fi
}


if [ $# != 1 ] ; then
	help_info
	usage
	exit 1
fi

if [ $1 -eq 0 ]; then
	check_tools
	create_bin
	install
	exit 0
fi

if [ $1 -eq 1 ]; then
	uninstall
	exit 0
fi

help_info
usage
exit 1