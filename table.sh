#!/usr/bin/env bash

create_table(){
        local db=$1
    read -r -p "Enter Table name: " table

    if [[ $table =~ " " ]]; then
        echo "Error: table name can't have a space"
        return 1
    
    elif ! is_valid "$table"; then
            echo "Error: table name must be like (student, student_t ..etc)"
            return 1
    fi

    # number of cols
    read -r -p "Enter number of cols: " cols

    if ! [[ "$cols" =~ ^[0-9]+$ ]] || (( cols <= 0 )); then
    echo "Error: columns must be a positive number"
    return 1
  fi

  col_names=()
  col_types=()
  for ((i=0; i<cols; i++));
  do
    read -r -p "Enter column name: " cname

    if [[ $cname =~ " " ]]; then
    echo "Error  col name can't have spaces"
    return 1
    fi
    if ! is_valid "$cname" ; then
        echo "Error: col name must be like (st_id, stID ...etc)"
        return 1
    fi
    read -r -p "Enter type of the Column (int/string): " ctype

    case $ctype in
    int|string)
    ;;
    *)
    echo "type must be int/string"
    return 1
    ;;
    esac

    col_names+=($cname)
    col_types+=($ctype)
    done

     echo "Columns saved:"
  for ((i=0; i<cols; i++)); do
    echo "  ${col_names[i]} : ${col_types[i]}"
  done
  #=--------------------------
    echo "Choose Primary Key column number (1-$cols): "
  select pkcol in "${col_names[@]}"; do
    if [[ -z "$pkcol" ]]; then
      echo "Invalid choice"
      return 1
    fi
    pk="$REPLY"
    break
  done
    {
    echo "cols=$cols"
    echo "pk=$pk"
    for ((i=1; i<=cols; i++)); do
      echo "col$i=${col_names[i-1]}:${col_types[i-1]}"
    done
  } > "$path/$db/$table.meta"

  : > "$path/$db/$table.data"
}

list_tables() {
  local db="$1"
  ls -1 "$path/$db" | sed 's/\.meta$//' | grep -v '\.data$'
}

insert_into_table() {
  local db="$1"

  echo "Choose table to insert data:"
  select table in $(list_tables "$db"); do
    if [[ -z "$table" ]]; then
      echo "Invalid choice"
      return 1
    fi
    break
  done

  local meta="$path/$db/$table.meta"
  local data="$path/$db/$table.data"


cols=$(awk -F= '{
      if ($1 == "cols"){
        print $2
      }
}' "$meta")
pk=$(awk -F= '{
  if ($1 == "pk"){
      print $2
  }
}' "$meta")
col_names=()
col_types=()

for ((i=1; i<=cols; i++)); do

  line=$(
    awk -F= -v col="col$i" '
      $1 == col {
        print $2
      }
    ' "$meta"
  )

  name=$(echo "$line" | awk -F: '{ print $1 }')
  type=$(echo "$line" | awk -F: '{ print $2 }')

  col_names+=("$name")
  col_types+=("$type")

done
values=()
for ((i=0; i<cols; i++)); do
  read -r -p "Enter ${col_names[i]} (${col_types[i]}): " v


  case "${col_types[i]}" in
    int)
      if ! [[ "$v" =~ ^[0-9]+$ ]]; then
        echo "Error: ${col_names[i]} must be an integer"
        return 1
      fi
      ;;
    string)
      if [[ -z "$v" ]]; then
        echo "Error: ${col_names[i]} must not be empty"
        return 1
      fi
      ;;
  esac

  values+=("$v")
 

done

pk_val="${values[pk-1]}"

if awk -F: -v p="$pk" -v val="$pk_val" '{
  if ($p == val) {
    exit 0
  }
}
END { exit 1 }' "$data"
then
  echo "Error: primary key '$pk_val' already exists"
  return 1
fi

(IFS=:; echo "${values[*]}") >> "$data"
echo "Inserted successfully into $table"


}
select_from_table() {
  local db="$1"

  echo "Choose table to select from:"
  select table in $(list_tables "$db"); 
  do
    if [[ -z "$table" ]]; then
    echo "Invalid choice" 
     return 1
     fi
    break
  done

  local meta="$path/$db/$table.meta"
  local data="$path/$db/$table.data"

cols=$(awk -F= '{
  if ($1 == "cols") {
    print $2
  }
}' "$meta")

  col_names=()
  local i line name
  for ((i=1; i<=cols; i++)); do
    line=$(awk -F= -v col="col$i" '$1==col {print $2}' "$meta")
    name="${line%%:*}"
    col_names+=("$name")
  done

  echo "---- $table ----"

  for ((i=0; i<cols; i++)); do
    printf "%-15s" "${col_names[i]}"
  done
  echo
  echo "-----------------------------------------------"
while IFS=':' read -r -a row; do
  for ((i=0; i<cols; i++)); do
    printf "%-16s" "${row[i]}"
  done
  echo
done < "$data"

}
delete_from_table() {
  local db="$1"

  echo "Choose table to delete from:"
  select table in $(list_tables "$db"); do
    if [[ -z "$table" ]];then
     echo "Invalid choice"
     return 1
     fi
    break
  done

  local meta="$path/$db/$table.meta"
  local data="$path/$db/$table.data"
  local tmp="$path/$db/$table.tmp"

 touch "$tmp"
    > "$tmp"


  local pk
  pk=$(awk -F= '{
        if($1 == "pk"){
          print $2
        }
  }' "$meta")

  read -r -p "Enter PK value to delete: " pk_val
  if [[ -z "$pk_val" ]]; then
    echo "Error: PK value cannot be empty"
    return 1
  fi

  deleted=0

  while IFS=':' read -r -a row; do
    if [[ "${row[pk-1]}" == "$pk_val" ]]; then
      deleted=1
      continue
    fi

    IFS=':'
    echo "${row[*]}" >> "$tmp"
    unset IFS
  done < "$data"

  mv "$tmp" "$data"

  if [[ $deleted -eq 1 ]]; then
    echo "Deleted row with PK=$pk_val"
  else
    echo "No row found with PK=$pk_val"
  fi
}

drop_table(){

  echo "choose table to drop"
    
      local db=$1



    select table in $(list_tables "$db");
    do
      if [[ -z $table ]]; then

            echo "invalid choice";
            return 1
            fi
            read -r -p "Are you sure to delete $table? (y/n): " ans
                local meta="$path/$db/$table.meta"
                local data="$path/$db/$table.data"
       case $ans in
          Y|y)
            rm -r $meta
            echo "Dropped: $table"
            ;;
            *)
            echo "Cancelled"
            ;;
            esac
            break
    done
  

}

table_menu(){
   db="$1"
  

  menu=("Create Table" "List Tables" "Insert Into Table" "Select From Table" "Delete From Table" "Drop Table" "Back")
  select choice in "${menu[@]}"; do
    case "$choice" in
      "Create Table") 
      create_table "$db"; 
      break 
      ;;
      "List Tables") 
      list_tables "$db"; 
      break 
      ;;
      "Insert Into Table") insert_into_table "$db"; 
      break ;;
      "Select From Table") select_from_table "$db"; 
      break ;;
      "Delete From Table") delete_from_table "$db"; 
      break ;;

      "Drop Table") 
      drop_table "$db"; 
      break ;;
      "Back") break ;;
      *) echo "Invalid choice"; break ;;
    esac
  done

  
}
