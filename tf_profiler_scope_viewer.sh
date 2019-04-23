#!/bin/bash
filename=$1

#   30 - black   34 - blue
#   31 - red     35 - magenta
#   32 - green   36 - cyan
#   33 - yellow  37 - white

BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

awk_functions='
function get_indent(num){
    res=""
    inc="  "
    for(i=0;i<num;i++){
        res=sprintf("%s%s", res, inc)
    }
    return res
}
function get_indent_num(line){
    match(line, /^ */);
    return RLENGTH/2
}
function time2us(time){
    match(time, /([0-9.]*)([a-z]*)/, a)
    if(a[2]=="sec") return a[1]*1000000
    if(a[2]=="ms") return a[1]*1000
    if(a[2]=="us") return a[1]
    else return 0
}
function find_total_exec_time(line){
    match(line, / \((.*),/, a);
    split(a[1],b,",")
    split(b[1],c,"/")
    return c[2]
}
function print_with_lineno_percent(lineno, line, total){
    exec_time=find_total_exec_time(line)
    time_in_us=time2us(exec_time)
    time_in_percent=time2us(exec_time)/time2us(total)*100
    if(time_in_us==0)
        printf "%05d %s\n", lineno, line
    else if(time_in_percent>10)
        printf "%05d %s | '$RED' %.2f% '$WHITE' \n", lineno, line, time_in_percent 
    else
        printf "%05d %s | %.2f%\n", lineno, line, time_in_percent 
}
'

total_time=$(awk "$awk_functions"'/_TFProfRoot/{print find_total_exec_time($0)}' $filename)

echo $total_time
awk_print='{print_with_lineno_percent(NR,$0,"'$total_time'")}'

awk_range='/Model Analysis Report/{flag=1}/End of Report/{flag=0}!flag{next}'
awk_body='get_indent_num($0)<=2'$awk_print
#awk_end='END{print get_indent_num("    a")}'
awk_end='END{}'
awk_sh="$awk_functions$awk_range$awk_body"
awk_full="$awk_sh$awk_end"

#get_indent(){
#    local num=$1
#    local res=''
#    local inc='  '
#    for i in $(seq 1 $num)
#    do
#        res="$res$inc"
#    done
#    echo $res
#}
#res=$(get_indent 3)
#echo -n "a${res}a"

awk "$awk_full" $filename | head -50


while :
do
    read -e -p "
    List the line number: " lineno
    #append condition to awk_sh
    #give start line, postpend *
    #flagi until same indent as start

    linestart=$lineno
    lineend=$(awk "$awk_full" $filename | awk "/^$lineno/"'{getline;print substr($0,1,5)}')
    indent=$(awk "$awk_full" $filename | awk "$awk_functions""/^$lineno/"'{print get_indent_num(substr($0,7))}')
    indent=$((indent+1))

    #Below lines are for working under Mac
    linestart=$(bc<<<$linestart)
    lineend=$(bc<<<$lineend)

    awk_new="NR>$linestart&&NR<$lineend"'&&get_indent_num($0)=='"$indent"$awk_print
    echo
    echo
    awk_sh="$awk_sh$awk_new"
    awk_full="$awk_sh$awk_end"

    awk_post="/^$lineno/"'{print "'$GREEN'" $0; next}1'
    awk "$awk_full" $filename | awk "$awk_post" | less -R
    echo current line range: $linestart, $lineend
    echo current indent level: $indent
done
