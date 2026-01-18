#!/usr/bin/env bash

path="./DBMS"


is_valid(){

    [[ $1 =~ ^[a-zA-Z][0-9]*$ ]]
}

db_exists(){
  [[ -d "$path/$1"]]
}

create_db(){

    read -r -p "Enter database name: " db

    if ! is_valid $db; then
    echo "invalid name, database name be like (myDatabase, mydatabase2, my_database)"
    
    
    elif db_exists $db; then
    echo "database already exists"

    else; then
    mkdir $path/$db
    echo `$db has been created`
    fi
}
list_database(){

    ls -d $path
}

connect_db(){

   $list=$(list_database)
    let counter=0
   select db in ${list[@]}; 
   do
    echo "connected to: $db"
    done    
}


drop_database(){


    select db in ${list[@]}
    do
        rm -r /$path/$db
    done

}


menu=("CreateTable" "List DataBases" "drop database"  "Exit" )
select in ${menu[@]}
do
case $choice in

create_db)
break
;;
list_database)
break
;;
drop_database)
break
;;
*)
return 1
;;
esac
done
