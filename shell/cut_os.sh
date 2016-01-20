cmd=""
arrays=("DHCP Server" "SNMP" "Gome GUI" "Apache")
function list_all()
{
for ((i=0;i<${#arrays[@]};i++))
do
   echo $i ${arrays[$i]}
done
   echo select:
}

function p()
{
    
    echo "GUI             print module list"
    echo "Web Server      print module list"
    echo "NFS             print module list"
    echo "FTP             print module list"
}
function help()
{
    echo "p      print module list"
    echo "add    add a module to repo"
    echo "del    del a module from repo"
    echo "l      list all modules"
}

function main()
{
    echo "welcome use OS minimize system"
    while [[ x$cmd!=x"quit"  ]]
    do 
        printf ">"
        read cmd
#        if [ x$cmd==x"quit" ];then
#            break;
#        fi
        echo "input:${cmd}"
        ${cmd}
    done
    
}

main



