
tmp=xxx

function read_dir(){
    for file in `ls $1`
    do
        if [ -d $1"/"$file ]
        then
            read_dir $1"/"$file
        else
            tmp=$1"/"$file 
            echo $tmp
            tmp=${tmp//（/(}
            tmp=${tmp//）/)}
            echo $tmp
            mv $1"/"$file $tmp
        fi
    done
}

read_dir /Users/xuhj/Documents/Github/xuhj2015.github.io/source/_posts