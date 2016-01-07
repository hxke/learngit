#!/bin/sh
myFile="/SmartGrid/etc/iftab"
myTempFile="/SmartGrid/etc/iftabTem"

#8500 all slot on condition can get slotnum

sort_by_pci()
{
    busNum=4
    flag=0
    #busAddr for store businfo
    #slotNum for store slot

    #slot1 0000:00:02.0 0000:00:02.1
    #slot2 0000:00:02.2  0000:00:02.3
    #slot3 0000:00:03.0  0000:00:03.1
    #slot4 0000:00:03.2 0000:00:03.3
    #mgmt bus:0000:00:1c.1

    busAddr=(0000:00:02.0 0000:00:02.2 0000:00:03.0 0000:00:03.2)
    
    Fiber_Seq=(1 0 3 2 5 4 7 6)
    Twisted_Seq=(4 0 5 1 6 2 7 3)
    Fast_Ge_Seq=(1 0)

    temp_i=0
    for ((i=0;i<$busNum;i++))
    do
        #if in igb then GE,if in ixgbe 10GE

        temp=`ls -l /sys/bus/pci/drivers/igb/|grep ${busAddr[$i]}|wc -l`
        if [ $temp -gt 0  ]; then
            let temp_i=$i+1
            slotNum[$i]=GE$temp_i.
            continue
        fi

        temp=`ls -l /sys/bus/pci/drivers/ixgbe/|grep ${busAddr[$i]}|wc -l`
        if [ $temp -gt 0  ]; then
            let temp_i=$i+1
            slotNum[$i]=10GE$temp_i.
            continue
        fi

    done

    echo ${slotNum[*]}
    #loop for assign to every slot

    for ((i=0;i<$busNum;i++))
    do
        if [ $flag -eq 0 ]; then
            echo $myFile
            flag=1
            #judge if file exist, back up and re-create
            if [ -e "$myFile" ]; then
                echo "file exist,bak created"
                mv $myFile "$myFile.bak"
                rm -f $myFile
                touch $myFile
            fi
        fi

        #filter by bus address
        Num2=`ls -l /sys/bus/pci/drivers/igb/|grep ${busAddr[$i]}|wc -l`
        if [ $Num2 -gt 0 ]; then
          tempStr="123456789"

          if [ "${busAddr[$i]}"x = "0000:00:02.0"x ]; then
            tempStr="0000:00:02.1"
          elif [ "${busAddr[$i]}"x = "0000:00:02.2"x ]; then
            tempStr="0000:00:02.3"
          elif [ "${busAddr[$i]}"x = "0000:00:03.0"x ]; then
            tempStr="0000:00:03.1"
          elif [ "${busAddr[$i]}"x = "0000:00:03.2"x ]; then
            tempStr="0000:00:03.3"
          fi
 
          arrMac=(`find /sys -name address|xargs grep ":"|grep -e ${busAddr[$i]} -e $tempStr|awk -F 'address:' '{print $2}'`)

          for((j=1;j<=8;j++))
            do
                #add . to slot name,if mgmt:no num
                echo ${slotNum[$i]}${j} mac ${arrMac[${j}-1]}
                echo ${slotNum[$i]}${j} mac ${arrMac[${j}-1]} >>$myFile

            done
            continue
        fi

        Num2=`ls -l /sys/bus/pci/drivers/ixgbe/|grep ${busAddr[$i]}|wc -l`
        if [ $Num2 -gt 0 ]; then
           arrMac=(`find /sys -name address|xargs grep ":"|grep ${busAddr[$i]}|awk -F 'address:' '{print $2}'`)

           for((j=1;j<=2;j++))
           do
               #add . to slot name,if mgmt:no num
               echo ${slotNum[$i]}${j} mac ${arrMac[${j}-1]}
               echo ${slotNum[$i]}${j} mac ${arrMac[${j}-1]} >>$myFile
           done
        fi
    done

    mgmtMac=`find /sys -name address|xargs grep ":"|grep "0000:00:1c.1"|awk -F 'address:' '{print $2}'`
    echo mgmt mac $mgmtMac
    echo mgmt mac $mgmtMac >>$myFile
}

sort_by_port()
{
    #8500 all slot on condition can get slotnum

    Twisted_Seq=(1 0 3 2 5 4 7 6 9 8 11 10 13 12 15 14 17 16 19 18 21 20 23 22)
    Fiber_Seq=(4 0 5 1 6 2 7 3 12 8 13 9 14 10 15 11 20 16 21 17 22 18 23 19)
    Fast_Ge_Seq=(1 0 3 2 5 4)

    arrayTemp2=()

    array1=(`cat $myFile|awk '{print $1}'`)
    array2=(`cat $myFile|awk '{print $3}'`)
    portsNum=${#array1[@]}
    echo ${array1[*]}
    echo ${array2[*]}

    arrFiberName=()
    arrFiberAddr=()

    arrOtherName=()
    arrOtherAddr=()

    mgmtMacAddr=""
    for ((i=0;i<$portsNum;i++))
    do
        tempStr=`ethtool ${array1[$i]}|grep "Port:"|awk '{print $2}'`

        if test "Twisted" = "$tempStr"; then

            if test "mgmt" = ${array1[$i]}; then
                mgmtMacAddr=${array2[$i]}
                continue
            fi
            arrayTemp1[${#arrayTemp1[@]}]=${array1[$i]}
            arrayTemp2[${#arrayTemp2[@]}]=${array2[$i]}

        elif test "FIBRE" = "$tempStr"; then
            arrFiberName[${#arrFiberName[@]}]=${array1[$i]}
            arrFiberAddr[${#arrFiberAddr[@]}]=${array2[$i]}
        elif test "Other" = "$tempStr"; then
            arrOtherName[${#arrOtherName[@]}]=${array1[$i]}
            arrOtherAddr[${#arrOtherAddr[@]}]=${array2[$i]}
        fi

    done

     tabspace=" "
     PortsToSort=(${arrayTemp1[*]}$tabspace${arrFiberName[*]}$tabspace${arrOtherName[*]})


    for var in ${PortsToSort[*]}
    do
        ifconfig $var down
    done

    arrayTemp3=()
    for((i=0;i<${#arrayTemp2[@]};i++))
    do
        arrayTemp3[$i]=${arrayTemp2[${Fiber_Seq[${i}]}]}
    done

    arrFiberRealSeq=()
    for((i=0;i<${#arrFiberAddr[@]};i++))
    do
        arrFiberRealSeq[$i]=${arrFiberAddr[${Twisted_Seq[$i]}]}
    done

    arrOtherRealSeq=()
    for((i=0;i<${#arrOtherAddr[@]};i++))
    do
        echo ${Fast_Ge_Seq[$i]}
        echo ${arrOtherAddr[*]}
        arrOtherRealSeq[$i]=${arrOtherAddr[${Fast_Ge_Seq[$i]}]}
    done

    FinalMacAddressSeq=(${arrayTemp3[*]}$tabspace${arrFiberRealSeq[*]}$tabspace${arrOtherRealSeq[*]})
    echo ${PortsToSort[*]} 
    echo ${FinalMacAddressSeq[*]}

    rm -f $myFile
    rm -f $myTempFile

    for ((i=0;i<${#PortsToSort[@]};i++))
    do
        echo ${PortsToSort[$i]}T mac ${FinalMacAddressSeq[$i]}>>$myTempFile
        echo ${PortsToSort[$i]} mac ${FinalMacAddressSeq[$i]}>>$myFile
    done
    echo mgmt mac $mgmtMacAddr>>$myFile

    ifrename -c $myTempFile
    rm -f $myTempFile
    ifrename

    for var in ${PortsToSort[*]}
    do
        ifconfig $var up
    done

    return
}

sort_by_pci
ifrename
sort_by_port

