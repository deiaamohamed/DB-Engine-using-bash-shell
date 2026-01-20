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

    if [[ "$db" =~ " " ]]; then
    echo "Error: database name must not contain spaces"
    elif ! is_valid "$db"; then
        echo "Error: database name must start with a letter and contain only letters, numbers, or _"
    elif db_exists "$db"; then
        echo "Database already exists"
    else
        mkdir -p "$path/$db"
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
        source ./table.sh
        table_menu "$db"
        fi
    break
    done    
}


drop_database(){


    select db in $(list_database)
    do

        if [[ -z $db ]]; then
            echo "invalid input"
        else 
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
            fi
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
echo "==================================================================="
if [[ $flag == 0 ]]; then
    break
    fi
done