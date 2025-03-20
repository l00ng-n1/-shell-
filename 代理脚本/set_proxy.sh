#!/bin/bash
#
#********************************************************************
#Author:            l00n9
#********************************************************************
# source set_proxy.sh start
# source set_proxy.sh stop

PROXY_SERVER_IP=10.0.0.1
PROXY_PORT=7890
#PROXY_PORT=10808

color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "    
    elif [ $2 = "failure" -o $2 = "1"  ] ;then 
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo 
}

start () {
    export http_proxy=$PROXY_SERVER_IP:$PROXY_PORT
    export https_proxy=$PROXY_SERVER_IP:$PROXY_PORT
    export ftp_proxy=$PROXY_SERVER_IP:$PROXY_PORT
    export NO_PROXY=".l00n9.icu,10.0.0.0/24,10.244.0.0/16,10.96.0.0/12"

    if [ $? -eq 0 ] ;then 
        color "代理配置完成!" 0  
    else
        color "代理配置失败!" 1
    exit 1
    fi  
}

stop () {
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    
    if [ $? -eq 0 ] ;then
        color "代理取消完成!" 0    
    else
        color "代理取消失败!" 1
    exit 1
    fi
}

usage () {
    echo "Usage: $(basename $0) start|stop"
    exit 1
}

case $1 in 
start)
    start
    ;;
stop)
    stop
    ;;
*)
    usage
    ;;
esac


