#!/usr/bin/env bash

path="./DBMS"

if [[ ! -d $path ]]; then
    mkdir $path
fi


is_valid(){

    [[ $1 =~ ^[a-zA-Z][A-Za-z0-9_]*$ ]]
}

db_exists(){
  [[ -d "$path/$1" ]]
}

create_db(){

    read -r -p "Enter database name: " db

    if ! is_valid $db; then
    echo "invalid name, database name be like (myDatabase, mydatabase2, my_database)"
    
    
    elif db_exists $db; then
    echo "database already exists"

    else
    mkdir $path/$db
    echo "$db has been created"
    fi
}
list_database(){

    ls -1 $path 
}

connect_db(){

   
    let counter=0
   select db in $(list_database); 
   do
        if [[ -z $db ]]; then
            echo "Invalid choice"
        else
        echo "connected to: $db"
        fi
    break
    done    
}


drop_database(){


    select db in $(list_database)
    do
       read -r -p "Are you sure to delete $db? (y/n): " ans
       case $ans in
          Y|y)
            rm -r $path/$db
            echo "Dropped: $db"
            ;;
            *)
            echo "Cancelled"
            ;;
            esac
            break
    done

}
flag=1
while true
do
menu=("Create Database" "List DataBases" "Connect Database" "drop database"  "Exit" )
select choice in "${menu[@]}";
do
case $choice in

"Create Database") create_db; 
break
;;
"List DataBases") list_database;
break
;;
"Connect Database") connect_db;
break
;;
"drop database") drop_database;
break
;;
"Exit")
     echo "bye bye :D"
     flag=0
        
break
;;
*) echo "Invaild input"; break;;
esac
done
if [[ $flag == 0 ]]; then
    break
    fi
done